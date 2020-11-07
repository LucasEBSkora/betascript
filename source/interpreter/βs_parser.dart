import 'expr.dart';
import 'stmt.dart';
import 'token.dart';
import 'βs_interpreter.dart';
import 'βscript.dart';
import '../sets/sets.dart';

class ParseError implements Exception {}

///The class that turns sequences of tokens into Abstract Syntax trees.
class BSParser {
  ///The list of tokens being parsed
  final List<Token> _tokens;
  final BSInterpreter _interpreter;
  //The token currently being parsed
  int _current;

  BSParser(List<Token> this._tokens, this._interpreter) {
    _current = 0;
  }

  //The parser works by implementing the rules in the language's formal grammar,
  //which are described in 'formal grammar representation.txt'

  ///This function is basically this rule:
  ///<program> ::= <declaration> <program>| <linebreak> <program> | <unterminated_optional_stmt> eof | eof
  List<Stmt> parse() {
    List<Stmt> statements = new List();

    //ignores linebreaks here so it doesn't have to go all the way down the recursion to do it
    while (!_isAtEnd()) {
      if (_match(TokenType.lineBreak)) continue;
      var declaration = _declaration();
      if (declaration != null) statements.add(declaration);
    }

    return statements;
  }

  ///<declaration> ::= <class_decl> | <rou_decl> | <var_decl_stmt> | <statement>
  Stmt _declaration() {
    try {
      if (_match(TokenType.classToken)) return _classDeclaration();

      ///<rou_decl> ::= "routine" <routine>
      if (_match(TokenType.routine)) return _routine("routine");
      if (_match(TokenType.let)) return _varDeclaration();
      return _statement();
    } on ParseError {
      _synchronize();
      return null;
    } on SetDefinitionError catch (e) {
      print(e.message);
      _synchronize();
      return null;
    }
  }

  ///<class_decl> ::= "class" <whitespace> <identifier> <{> <routines> <}>
  ///             | "class" <whitespace> <identifier> <whitespace> "<" <whitespace> <identifier> <{> <routines>  <}>
  Stmt _classDeclaration() {
    Token name = _consume(TokenType.identifier, "Expect class name");

    //"<" <whitespace> <identifier>
    VariableExpr superclass = null;
    if (_match(TokenType.less)) {
      _consume(TokenType.identifier, "Expect superclass name");
      superclass = new VariableExpr(_previous());
    }

    //linebreaks after { dealt with by scanner
    _consume(TokenType.leftBrace, "Expect '{' before class body");

    List<RoutineStmt> methods = new List();

    //<routines> ::= routine <routines> | <whitespace_or_linebreak> <routines> ""
    while (!_check(TokenType.rightBrace) && !_isAtEnd())
      if (_check(TokenType.lineBreak)) {
        _advance();
      } else {
        methods.add(_routine("method"));
      }

    _consume(TokenType.rightBrace, "Expect '}' after class body");

    return new ClassStmt(name, superclass, methods);
  }

  ///kind is either 'routine' or 'method'
  ///<routine> ::= <identifier> <(> <parameters> <)> <whitespace_or_linebreak> <block>
  ///            | <identifier> <(> <)> <whitespace_or_linebreak> <block>
  RoutineStmt _routine(String kind) {
    Token name = _consume(TokenType.identifier, "Expect $kind name.");

    //linebreaks after this dealt with by scanner
    _consume(TokenType.leftParentheses, "Expect '(' after $kind name;");

    List<Token> parameters = new List();

    //<parameters> ::= <identifier> | <identifier> <whitespace> "," <whitespace_or_linebreak> <parameters>
    if (!_check(TokenType.rightParentheses)) {
      do {
        if (_match(TokenType.lineBreak)) continue;
        parameters.add(_consume(TokenType.identifier, "Expect parameter name"));
      } while (_match(TokenType.comma));
    }

    //possible linebreak here handled by the scanner
    _consume(TokenType.rightParentheses, "Expect ')' after parameters.");

    _match(TokenType.lineBreak);
    _consume(TokenType.leftBrace, "Expect '{' after routine parameters");
    List<Stmt> body = _block();
    return new RoutineStmt(name, parameters, body);
  }

  ///<var_decl_stmt> ::= <unterminated_var_decl_stmt> <delimitator>

  ///<unterminated_var_decl_stmt> ::= <let> <identifier>
  ///                               | <let> <identifier> <assigment_operator> <expression>
  ///                               | <let> <identifier> <(>  <)> <assigment_operator> <expression>
  ///                               | <let> <identifier> <(> <parameters> <)> <assigment_operator> <expression>
  ///<let> ::= "let" <whitespace>
  ///<assigment_operator> ::= <whitespace> "=" <whitespace_or_linebreak>

  Stmt _varDeclaration() {
    Token name = _consume(TokenType.identifier, "Expect variable name");

    List<Token> parameters = null;
    if (_match(TokenType.leftParentheses)) {
      parameters = List();

      do {
        if (_check(TokenType.rightParentheses)) break;
        //linebreaks after ( and , handled by scanner
        parameters.add(_consume(TokenType.identifier, "Expect parameter name"));
      } while (_match(TokenType.comma));

      //linebreaks right before ) handled by scanner

      _consume(TokenType.rightParentheses, "Expect ')' after parameters.");
    }
    if (parameters?.isEmpty ?? true) parameters = null;

    Expr initializer = null;
    if (_match(TokenType.assigment)) {
      //linebreak after = handled by scanner
      initializer = _expression();
    }

    _consumeAny([TokenType.semicolon, TokenType.lineBreak],
        "Expect ';' or line break after variable declaration");
    return new VarStmt(name, parameters, initializer);
  }

  ///<statement> ::= <expr_stmt> | <for_stmt> | <if_stmt> | <print_stmt> | <return_stmt> | <while_stmt> | <block> | <directive>
  Stmt _statement() {
    if (_match(TokenType.forToken)) return _forStatement();
    if (_match(TokenType.ifToken)) return _ifStatement();
    if (_match(TokenType.print)) return _printStatement();
    if (_match(TokenType.returnToken)) return _returnStatement();
    if (_match(TokenType.whileToken)) return _whileStatement();
    //might be an expression statement with a Set definition or a block
    if (_match(TokenType.leftBrace)) return _parseLeftBrace();
    if (_match(TokenType.hash)) return _directive();
    return _expressionStatement();
  }

  ///<expr_stmt> ::= <expression> <delimitator>
  Stmt _expressionStatement() {
    Expr expr = _expression();
    _checkTerminator("expression");
    return new ExpressionStmt(expr);
  }

  ///<for_stmt> ::= "for" <(> <for_stmt_init_clause> <whitespace> ";" <whitespace_or_linebreak> <for_stmt__clause> <whitespace> ";"
  ///               <whitespace_or_linebreak> <for_stmt__clause>  <)> <whitespace_or_linebreak> <statement>
  ///<for_stmt_init_clause> ::= <var_decl> | <expression> | ""
  ///<for_stmt__clause> ::= <expression> | ""
  Stmt _forStatement() {
    Token token = _previous();

    _consume(TokenType.leftParentheses, "Expect '(' after 'for'.");

    //linebreaks after left parentheses handled by the parser

    Stmt initializer;

    //the initializer may be empty, a variable declaration or any other expression
    if (_match(TokenType.semicolon)) {
      initializer = null;
    } else if (_match(TokenType.let)) {
      initializer = _varDeclaration();
    } else {
      initializer = _expressionStatement();
    }

    //linebreaks after semicolons handled by the parser

    //The condition may be any expression, but may also be left empty
    Expr condition = (_check(TokenType.semicolon)) ? null : _expression();

    _consume(TokenType.semicolon, "Expect ';' after loop condition.");

    //linebreaks after semicolons handled by the parser

    Expr increment =
        (_check(TokenType.rightParentheses)) ? null : _expression();

    //linebreaks before ) handled by scanner

    _consume(TokenType.rightParentheses,
        "Expect ')' after increment in for statement");
    Stmt body = _statement();

    if (increment != null) {
      body = new BlockStmt([body, new ExpressionStmt(increment)]);
    }
    if (condition == null) condition = new LiteralExpr(true);

    body = new WhileStmt(token, condition, body);

    if (initializer != null) body = new BlockStmt([initializer, body]);

    return body;
  }

  ///<if_stmt> := <if_clause> | <if_clause> <whitespace_or_linebreak> <else_clause>
  ///<if_clause> ::= "if" <(> <expression> <)> <whitespace_or_linebreak> <statement>
  ///<else_clause> ::= "else" <whitespace_or_linebreak> <statement>
  Stmt _ifStatement() {
    _consume(TokenType.leftParentheses, "Expect '(' after 'if'.");
    //linebreaks after left parentheses handled by the parser
    Expr condition = _expression();

    //linebreak before ) handled by scanner

    _consume(TokenType.rightParentheses, "Expect ')' after if condition.");

    _match(TokenType.lineBreak);

    Stmt thenBranch = _statement();

    //linebreak before else handled by scanner

    Stmt elseBranch = (_match(TokenType.elseToken)) ? _statement() : null;

    return new IfStmt(condition, thenBranch, elseBranch);
  }

  ///<print_stmt> ::= <unterminated_print_stmt> <delimitator>
  ///<unterminated_print_stmt> ::= "print" <expression>
  Stmt _printStatement() {
    if (_match(TokenType.lineBreak)) {
      _error(_previous(),
          "linebreak right after 'print' keyword not allowed. Please start the target expression in the same line.");
    }
    Expr value = _expression();
    _checkTerminator("print");
    return new PrintStmt(value);
  }

  ///<return_stmt> ::= "return" <whitespace> <expression> <whitespace> ";"
  ///                | "return" <whitespace> ";"
  ///                | "return" <whitespace> <expression> <whitespace> <linebreak>
  ///<unterminated_return_stmt> ::= "return" | "return" <whitespace> <expression>
  Stmt _returnStatement() {
    Token keyword = _previous();
    if (_match(TokenType.lineBreak)) {
      _error(_previous(),
          "linebreak not allowed immediately after return keyword! If you want to end the routine early, either write 'return null' or 'return;'");
    }
    Expr value =
        (_check(TokenType.semicolon)) ? LiteralExpr(null) : _expression();

    _checkTerminator("return");

    return new ReturnStmt(keyword, value);
  }

  ///<while_stmt> ::= "while" <(> <expression> <)> <statement>
  Stmt _whileStatement() {
    Token token = _previous();
    _consume(TokenType.leftParentheses, "Expect '(' after 'while'.");

    //linebreak after left parentheses handled by parser

    Expr condition = _expression();

    //linebreak before ) handled by scanner

    _consume(TokenType.rightParentheses, "Expect ')' after while condition.");

    _match(TokenType.lineBreak);

    Stmt body = _statement();

    return new WhileStmt(token, condition, body);
  }

  ///<block> ::= <{> <block_body> <}> | <{> <block_body> <unterminated_optional_stmt> <}>
  ///<block_body> ::= <whitespace_or_linebreak> <block_body> | <statement> <block_body> | ""
  List<Stmt> _block() {
    //The left brace was already consumed in _statement or _routine
    List<Stmt> statements = new List();

    while (!_check(TokenType.rightBrace) && !_isAtEnd()) {
      if (_match(TokenType.lineBreak)) continue;
      statements.add(_declaration());
    }

    _consume(TokenType.rightBrace, "Expect '}' after block.");

    return statements;
  }

  ///<expression> ::= <assigment>
  Expr _expression() {
    return _assigment();
  }

  ///<assigment> ::= <logic_or> | <calls> <identifier> <assigment_operator> <assigment>
  ///<calls> ::= <call> <whitespace> "." <whitespace_or_linebreak> <calls> | ""
  Expr _assigment() {
    //Assigment is hard because when you get to the "=" token, you already consumed the identifier token
    //and if it is something more complex, mainly envolving objects, it may be necessary to go many tokens back to discover
    //what is the identifier
    //So what we must do is first assume it goes to another rule (logicOr) and store the value of this expression
    //and if we really have an assigment, transform the previously parsed result into a assigment target

    Expr expr = _or();

    if (_match(TokenType.assigment)) {
      Token equals = _previous();
      //linebreaks here handled by scanner
      Expr value = _assigment();

      //This is why Grouping is considered a different type of expression: a = 1 is allowed, but (a) = 1 isn't.
      if (expr is VariableExpr) {
        Token name = expr.name;
        return new AssignExpr(name, value);
      } else if (expr is GetExpr) {
        return new SetExpr(expr.object, expr.name, value);
      }

      _error(equals, "Invalid assigment target");
    }

    return expr;
  }

  ///<logic_or> ::= <logic_and> | <logic_and> <whitespace> "or" <whitespace_or_linebreak> <logic_or>
  Expr _or() {
    Expr expr = _and();

    while (_match(TokenType.or)) {
      Token op = _previous();
      //linebreaks after 'or' keyword handled by scannner
      Expr right = _and();
      expr = new logicBinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///<logic_and> ::= <equality> | <equality> <whitespace> "and" <whitespace_or_linebreak> <logic_and>
  Expr _and() {
    Expr expr = _equality();

    while (_match(TokenType.and)) {
      Token op = _previous();
      //linebreaks after 'and' keyword handled by scanner
      Expr right = _equality();
      expr = new logicBinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///<equality> ::= <comparison> | <comparison> <whitespace> <equality_operator> <whitespace_or_linebreak> <equality>
  ///<equality_operator> ::= "==" | "==="
  Expr _equality() {
    Expr expr = _comparison();

    while (_matchAny([TokenType.equals, TokenType.identicallyEquals])) {
      Token op = _previous();
      //linebreaks after '==' operator handled by scanner
      Expr right = _comparison();
      expr = new BinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///<comparison> ::= <set_binary> | <set_binary> <whitespace> <comparison_operator> <whitespace_or_linebreak> <comparison>
  ///<comparison_operator> ::= ">" | ">=" | "<" | "<="
  Expr _comparison() {
    //follows the pattern in _equality

    Expr expr = _setBinary();

    while (_matchAny([
      TokenType.greater,
      TokenType.greaterEqual,
      TokenType.less,
      TokenType.lessEqual
    ])) {
      //linebreaks after the operators listed above handled by scanner
      expr = new BinaryExpr(expr, _previous(), _setBinary());
    }

    return expr;
  }

  ///<set_binary> ::= <addition> | <addition> <whitespace> <set_operator> <whitespace_or_linebreak> <set_binary>
  ///<set_operator> ::= "union" | "intersection" | "\" | "contained" | "disjoined" | "belongs"
  Expr _setBinary() {
    Expr expr = _addition();
    while (_matchAny([
      TokenType.union,
      TokenType.intersection,
      TokenType.invertedSlash,
      TokenType.contained,
      TokenType.disjoined,
      TokenType.belongs
    ])) {
      //linebreaks after these tokens handled by the scanner
      expr = new SetBinaryExpr(expr, _previous(), _addition());
    }

    return expr;
  }

  ///<addition> ::= <multiplication> | <multiplication> <whitespace> <addition_operator> <whitespace_or_linebreak> <addition>
  ///<addition_operator> ::= "-" | "+"
  Expr _addition() {
    //follows the pattern in _equality

    Expr expr = _multiplication();

    while (_matchAny([TokenType.minus, TokenType.plus])) {
      Token op = _previous();
      //linebreaks after the operators listed above handled by scanner
      Expr right = _multiplication();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///<multiplication> ::= <exponentiation> | <exponentiation> <whitespace> <multiplication_operator> <whitespace_or_linebreak> <multiplication>
  ///<multiplication_operator> ::= "*" | "/"
  Expr _multiplication() {
    //follows the pattern in _equality

    Expr expr = _exponentiation();

    while (_matchAny([TokenType.slash, TokenType.star])) {
      Token op = _previous();
      //linebreaks after the operators listed above handled by scanner
      Expr right = _exponentiation();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///<exponentiation> ::= <unary_left> | <unary_left> <whitespace> "^" <whitespace_or_linebreak> <exponentiation>
  Expr _exponentiation() {
    //follows the pattern in _equality

    Expr expr = _unary_left();

    while (_match(TokenType.exp)) {
      Token op = _previous();
      //linebreaks after '^' operator handled by scanner
      Expr right = _unary_left();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///<unary_left> ::= <unary_right> | <unary_left_operator> <whitespace_or_linebreak> <unary_left>
  ///<unary_left_operator> ::= "not" | "-" | "~"
  Expr _unary_left() {
    //this rule is a little different, and actually uses recursion. When you reach this rule, if you immediately find  '!', '-' or '~',
    //go back to the 'unary' rule

    if (_matchAny([TokenType.minus, TokenType.not, TokenType.approx])) {
      Token op = _previous();
      //linebreaks after the operators listed above handled by scanner
      Expr right = _unary_left();
      return new UnaryExpr(op, right);
    }

    //if it doesn't find any left-unary operators, looks for the right ones
    return _unary_right();
  }

  ///<unary_right> ::= <call> | <derivative> | <unary_right> <whitespace> <unary_right_operator>
  ///<unary_right_operator> ::= "!" | "'"
  Expr _unary_right() {
    Expr operand;
    //if it finds a 'del' token, parses a derivative
    if (_match(TokenType.del)) {
      operand = _derivative();
    } else {
      //in any other case, go to the 'call' rule
      operand = _call();
    }
    //keeps composing it until it's done
    while (_matchAny([TokenType.apostrophe, TokenType.factorial]))
      operand = UnaryExpr(_previous(), operand);

    return operand;
  }

  ///<call> ::= <primary> <whitespace> <routine_or_field>
  ///<routine_or_field> ::= ""
  ///                     | <(> <)> <routine_or_field>
  ///                     | <(> <arguments> <)> <routine_or_field> |
  ///                     | "." <whitespace_or_linebreak> <identifier> <routine_or_field>
  Expr _call() {
    Expr expr = _primary();

    //if after a primary expression you find a parentheses, parses it as a function call, and keeps doing it until you don't find more parentheses
    //to allow for things like getFunction()();
    while (true) {
      if (_match(TokenType.leftParentheses)) {
        //linebreak after ( handled by scanner
        expr = _finishCall(expr);
      } else if (_match(TokenType.dot)) {
        //linebreak after . handled by scanner
        Token name =
            _consume(TokenType.identifier, "Expect property name after '.'");
        expr = new GetExpr(expr, name);
      } else
        break;
    }

    return expr;
  }

  ///<arguments> ::= <expression> | <expression> <whitespace> "," <whitespace_or_linebreak> <arguments>
  Expr _finishCall(Expr callee) {
    List<Expr> arguments = new List();
    //If you immediately find the ')' token, there are no arguments to the function call

    if (!_check(TokenType.rightParentheses)) {
      //and if there are arguments, they are separeted by commas
      //do note that there is no max number of arguments. That might be a problem when (if) translating the interpreter to a lower level language.
      do {
        //linebreaks after '(' and ',' handled by scanner
        arguments.add(_expression());
      } while (_match(TokenType.comma));
    }

    //linebreak before ) handled by scanner

    Token paren =
        _consume(TokenType.rightParentheses, "Expect ')' after arguments.");

    return new CallExpr(callee, paren, arguments);
  }

  ///<derivative> ::= <partial_differential> <whitespace> "/" <whitespace_or_linebreak> <derivative_parameters>
  ///<partial_differential> ::=  "del" <(> <expression> <)>
  ///<derivative_parameters> ::= "del" <(> <arguments> <)>
  Expr _derivative() {
    Token keyword = _consume(TokenType.leftParentheses,
        "Expect '(' after del keyword - linebreaks not allowed between 'del' and '('");
    //linebreaks after '(' handled by scanner
    Expr derivand = _expression();
    //linebreak before ) handled by scanner
    _consume(TokenType.rightParentheses, "Expect ')' after derivand");
    _consume(TokenType.slash,
        "expect '/' after derivand - if you wanted to add a linebreak between ')' and '/', do it after the slash");
    //linebreaks after '/' handled by scanner
    _consume(TokenType.del, "expect second 'del' after derivand");
    _consume(TokenType.leftParentheses, "expect '(' after second del keyword");
    //linebreaks after '(' handled by scanner
    List<Expr> variables = List();
    if (_check(TokenType.rightParentheses)) {
      _error(_previous(),
          "at least one variable is necessary in derivative expression");
    }
    do {
      //linebreaks after '(' and ',' handled by scanner
      variables.add(_expression());
    } while (_match(TokenType.comma));

    //linebreaks before ')' handled by scanner

    _consume(
        TokenType.rightParentheses, "expect ')' after derivative variables");

    return new DerivativeExpr(keyword, derivand, variables);
  }

  /// <primary> ::= <set_definition> | number | string | "false" | "true" | "nil"
  ///            | <(> <expression> <)>
  ///            | <identifier> | "super" <whitespace> "." <whitespace_or_linebreak> <identifier>
  ///<set_definition> ::= "set" <whitespace_or_linebreak> <set_def> | <whitespace_or_linebreak> <set_def>
  ///<set_def> ::= <interval_definition> | <roster_set_definition> | <builder_set_definition>
  ///<interval_definition> ::= <left_interval_edge> expression <whitespace> "," <whitespace_or_linebreak> expression <right_interval_edge>                          <whitespace_or_linebreak> expression <whitespace_or_linebreak> <right_interval_edge>
  ///<left_interval_edge> ::= <[> | <(>
  ///<right_interval_edge> ::= <]> | <)>
  ///<roster_set_definition> ::= <{> <}> | <{> <arguments> <}>
  ///<builder_set_definition> ::= <{> "|" <whitespace_or_linebreak> <logic_or> <}>
  ///                           | <{> <arguments> <whitespace> "|" <whitespace_or_linebreak> <logic_or> <}>

  Expr _primary() {
    //since some tokens may both be sets and other types of syntax
    //(braces may be sets or blocks, parentheses may be groupings or intervals,
    //and one day square brackets may be index access/intervals and parentheses intervals/tuples)
    //we have to parse them assuming it can be either until we can be sure.

    //the "set" keyword MUST mean a set definition follows. If it doesn't, it's an error.
    if (_match(TokenType.setToken)) return _setDefinition();

    //number | string
    if (_matchAny([TokenType.number, TokenType.string])) {
      return new LiteralExpr(_previous().literal);
    }

    //false
    if (_match(TokenType.falseToken)) {
      return new LiteralExpr(false);
    }

    //true
    if (_match(TokenType.trueToken)) {
      return new LiteralExpr(true);
    }

    //nil
    if (_match(TokenType.nil)) return new LiteralExpr(null);

    //<(> <expression> <)>
    //or
    //<interval_definition> ::= <(> expression <whitespace> "," <whitespace_or_linebreak> expression <right_interval_edge>
    if (_match(TokenType.leftParentheses)) return _parseLeftParentheses();

    //<roster_set_definition> ::= <{> <}> | <{> <arguments> <}>
    //or
    //<builder_set_definition> ::= <{> "|" <whitespace_or_linebreak> <logic_or> <}>
    //                           | <{> <arguments> <whitespace> "|" <whitespace_or_linebreak> <logic_or> <}>
    //or
    //just a block
    if (_match(TokenType.leftBrace)) return _parseLeftBrace(true);

    //<interval_definition> ::= <[> expression <whitespace> "," <whitespace_or_linebreak> expression <right_interval_edge>
    if (_match(TokenType.leftSquare)) return _parseLeftSquare();

    //identifier
    if (_match(TokenType.identifier)) return new VariableExpr(_previous());
    if (_match(TokenType.thisToken)) return new ThisExpr(_previous());

    //"super" <whitespace> "." <whitespace_or_linebreak> <identifier>
    if (_match(TokenType.superToken)) {
      Token keyword = _previous();
      _consume(TokenType.dot,
          "Expect '.' after 'super' - if you want to add a linebreak, do it after the dot");
      //linebreaks after '.' handled by scanner
      Token method =
          _consume(TokenType.identifier, "Expect superclass method name");
      return new SuperExpr(keyword, method);
    }

    //if you get to this rule and don't find any of the above, you found a syntax error instead
    if (_previous().type == TokenType.lineBreak &&
        _checkAny([
          TokenType.comma,
          TokenType.dot,
          TokenType.minus,
          TokenType.plus,
          TokenType.slash,
          TokenType.star,
          TokenType.approx,
          TokenType.exp,
          TokenType.assigment,
          TokenType.equals,
          TokenType.identicallyEquals,
          TokenType.greater,
          TokenType.greaterEqual,
          TokenType.less,
          TokenType.lessEqual,
          TokenType.and,
          TokenType.or,
          TokenType.not,
          TokenType.elseToken
        ]))
      throw _error(_peek(),
          "missing left argument for operator. If you wanted to break an expression into multiple lines, do it after operators");
    else
      throw _error(_peek(), "Expect expression.");
  }

  Expr _setDefinition() {
    if (_match(TokenType.leftParentheses)) return _parseLeftParentheses(true);
    if (_match(TokenType.leftSquare)) return _parseLeftSquare(true);
    if (_match(TokenType.leftBrace)) return _parseLeftBrace(true);
    throw _error(_previous(), "Expecting Set definition after 'set' keyword");
  }

  ///<(> <expression> <)>
  ///or
  ///<interval_definition> ::= <(> expression <whitespace> "," <whitespace_or_linebreak> expression <right_interval_edge>
  Expr _parseLeftParentheses([bool mustBeSet = false]) {
    Token _left = _previous();
    //linebreaks after '(' handled by scanner
    Expr expr = _expression();

    if (_match(TokenType.comma)) {
      //in here we're sure that we're parsing an Interval
      Expr _expr = _expression();
      //linebreaks before ']' and ')' handled by scanner
      _consumeAny([TokenType.rightBrace, TokenType.rightParentheses],
          "Expected ] or ) ending interval definition");
      return new IntervalDefinitionExpr(_left, expr, _expr, _previous());
    }
    if (mustBeSet) throw _error(_previous(), "Expecting Interval definition");

    //linebreaks before ')' handled by scanner
    //if the ')' is not there, it's an error
    _consume(TokenType.rightParentheses, "Expect ')' after expression");
    return new GroupingExpr(expr);
  }

  ///<interval_definition> ::= <[> expression <whitespace> "," <whitespace_or_linebreak> expression <right_interval_edge>
  Expr _parseLeftSquare([bool mustBeSet = false]) {
    Token left = _previous();

    Expr expr = _expression();

    _consume(TokenType.comma, "Expecting comma in Interval definition");

    Expr _expr = _expression();

    //linebreaks before ']' and ')' handled by scanner

    _consumeAny([TokenType.rightBrace, TokenType.rightParentheses],
        "Expected ] or ) ending interval definition");
    return new IntervalDefinitionExpr(left, expr, _expr, _previous());
  }

  ///rosterSetDefinition -> "{" linebreak? ( expression ("," linebreak? expression)*)? linebreak? "}"
  ///or
  ///builderSetDefinition -> "{" linebreak? (expression, ("," expression)* )? "|" linebreak? expression linebreak? "}"
  ///or
  ///block -> "{" (declaration | linebreak)* "}"
  Object _parseLeftBrace([bool expectSet = false]) {
    Token _leftBrace = _previous();
    Expr _setReturn = null;

    //{} -> empty set
    if (_match(TokenType.rightBrace)) {
      if (expectSet) {
        return LiteralExpr(emptySet);
      } else {
        return ExpressionStmt(LiteralExpr(emptySet));
      }
    }

    //if we find a comma, we know it's a set definition
    //if we find a vertical bar, we know it's a builder set definition

    List<Expr> expressions = new List();

    Stmt first;

    if (!_check(TokenType.verticalBar)) first = _declaration();

    //assumes it is a block

    bool isSet = false;

    if (_match(TokenType.comma)) {
      if (first == null) _error(_previous(), "expect token before comma");
      if (first is ExpressionStmt) {
        expressions.add(first.expression);
      } else {
        _error(_previous(),
            "all elements in a roster set definition must evaluate to a number");
      }
      isSet = true;
      do {
        //linebreaks after ','  handled by scanner
        expressions.add(_expression());
      } while (_match(TokenType.comma));
    }

    //is a builder set
    if (_match(TokenType.verticalBar)) {
      if (first != null) {
        if (first is ExpressionStmt) {
          expressions.add(first.expression);
        } else {
          _error(_previous(),
              "all parameters in a builder set definition must evaluate to a variable");
        }
      }

      Token bar = _previous();
      Expr logic = _expression();
      //linebreak before } handled by scanner
      _consume(TokenType.rightBrace, "Expect '}' after builder set definition");
      List<Token> parameters;
      if (expressions.isNotEmpty) {
        parameters = List();
        for (Expr parameter in expressions) {
          if (parameter is VariableExpr) {
            parameters.add(parameter.name);
          } else {
            throw new SetDefinitionError(
                "parameter is not explicit variable name");
          }
        }
      }

      _setReturn = new BuilderDefinitionExpr(
          _leftBrace, parameters, logic, bar, _previous());
    } else if (isSet) {
      //Roster set
      //linebreak before } handled by scanner
      _consume(TokenType.rightBrace, "Expect '}' after roster set definition");

      _setReturn =
          new RosterDefinitionExpr(_leftBrace, expressions, _previous());
    }

    //if there is a single element, and it is a expression statement, assumes it's a RosterSet with a single element
    //if it isn't, assumes it is a block with a single
    if (_match(TokenType.rightBrace)) {
      if (first is ExpressionStmt) {
        _setReturn = new RosterDefinitionExpr(
            _leftBrace, [first.expression], _previous());
      } else
        return new BlockStmt([first]);
    }

    if (_setReturn != null) {
      if (expectSet)
        return _setReturn;
      else
        return ExpressionStmt(_setReturn);
    }

    List<Stmt> statements = new List();
    statements.add(first);

    while (!_check(TokenType.rightBrace) && !_isAtEnd()) {
      if (_match(TokenType.lineBreak)) continue;
      statements.add(_declaration());
    }

    _consume(TokenType.rightBrace, "Expect '}' after block.");
    return new BlockStmt(statements);
  }
  //Helper function corner

  ///returns whether the current token's type is 'type', consuming it if it is
  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  ///returns true if the current token matches any in 'types', consuming it if it does
  bool _matchAny(List<TokenType> types) {
    for (TokenType type in types) {
      if (_match(type)) return true;
    }
    return false;
  }

  ///returns whether the current token's type matches 'type'
  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  ///_check for many types
  bool _checkAny(List<TokenType> types) {
    if (_isAtEnd()) return false;
    return types.contains(_peek().type);
  }

  ///Goes to the next token, returning the current one. If already at the end, doesn't keep going
  ///(remember that, in theory, every list of tokens generated by BSScanner ends with an eof token)
  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  ///returns whether current token is the last one
  ///not adding the eof token would simply mean checking _current >= _tokens.length
  bool _isAtEnd() => _peek().type == TokenType.EOF;

  ///returns the current token without consuming it
  Token _peek() => _tokens[_current];

  ///return the token immediately before _current
  Token _previous() => _tokens[_current - 1];

  ///checks if the current token matches 'type' and consumes it, if it doesn't, causes an error
  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();

    //doesn't actually throw the error
    //So that it keeps parsing
    _error(_peek(), message);
    return null;
  }

  Token _consumeAny(List<TokenType> types, String message) {
    for (TokenType type in types) {
      if (_check(type)) return _advance();
    }

    _error(_peek(), message);
    return null;
  }

  ///Reports an error to the general interpreter and creates a ParseError without necessarily throwing it
  ParseError _error(Token token, String message) {
    BetaScript.error(token, message);
    return new ParseError();
  }

  ///When a syntax error is found, ignores the rest of the current expression by moving _current forward
  void _synchronize() {
    _advance();

    while (!_isAtEnd()) {
      if (_previous().type == TokenType.semicolon) return;

      switch (_peek().type) {
        case TokenType.classToken:
        case TokenType.routine:
        case TokenType.let:
        case TokenType.forToken:
        case TokenType.ifToken:
        case TokenType.whileToken:
        case TokenType.print:
        case TokenType.returnToken:
          return;
        default:
      }

      _advance();
    }
  }

  ///<directive> ::= "#" directiveName
  ///<directive_name ::=  a directive name is composed of anything that isn't whitespace. There is probably a simple way of expressing this in regEx,
  ///                     but i unforgivably don't know how to use them. basically, if it can be a twitter hashtag, it counts
  Stmt _directive() {
    DirectiveStmt stmt = DirectiveStmt(_previous(), _previous().literal);
    //if the directive is global, it is set directly in the global directives
    //if they're local, the interpreter will deal with it in time
    if (!_interpreter.directives.setIfGlobal(stmt.directive, true)) {
      return stmt;
    } else
      return null;
  }

  ///delimitator ::= <linebreak> | <;>
  void _checkTerminator(String type) {
    //'}' and eof are unconsumed terminators to deal with the fact something at the end of a program or block might not have a linebreak,
    //which should work. ',' and '|' are unconsumed terminator as a crutch to make sure that they the first expression after an ambiguous
    //'{'. Since none of these are consumed, they will still cause an error when in the wrong place, so this isn't going to allow weird stuff
    //(i hope)
    if (_checkAny([TokenType.semicolon, TokenType.lineBreak])) {
      _advance();
      return;
    }
    if (_isAtEnd() ||
        _checkAny(
            [TokenType.rightBrace, TokenType.comma, TokenType.verticalBar])) {
      return;
    }

    throw _error(_peek(), "Expect ';' or line break after $type value");
  }
}

//whitespace rules:

//<unterminated_optional_stmt> ::= <unterminated_print_stmt> | <unterminated_return_stmt> | <unterminated_var_decl_stmt> | <expression>
//<whitespace> ::= TAB <whitespace> | " " <whitespace> | ""
//<linebreak> ::= lineBreak <linebreak> | lineBreak
//<whitespace_or_linebreak> ::= <whitespace> <whitespace_or_linebreak> | <linebreak> <whitespace_or_linebreak> | ""

//whitespace treatment rules

//<;> ::= <whitespace> ";" <whitespace_or_linebreak>

//<(> ::= <whitespace> "(" <whitespace_or_linebreak>
//<)> ::= <whitespace_or_linebreak> ")" <whitespace>

//<[> ::= <whitespace> "[" <whitespace_or_linebreak>
//<]> ::= <whitespace_or_linebreak> "]" <whitespace>

//<{> ::= <whitespace> "{" <whitespace_or_linebreak>
//<}> ::= <whitespace_or_linebreak> "}" <whitespace>
