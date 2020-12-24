import 'package:meta/meta.dart';

import 'expr.dart';
import 'stmt.dart';
import 'token.dart';
import '../utils/three_valued_logic.dart';
import '../sets/sets.dart';

class ParseError implements Exception {}

///The class that turns sequences of tokens into Abstract Syntax trees.
class BSParser {
  ///The list of tokens being parsed
  final List<Token> _tokens;
  final Function _errorCallback;
  //The token currently being parsed
  int _current = 0;

  BSParser(this._tokens, this._errorCallback);

  //The parser works by implementing the rules in the language's formal grammar,
  //which are described in 'formal grammar representation.txt'

  ///This function is basically this rule:
  ///<program> ::= <declaration> <program>| <linebreak> <program> | <unterminated_optional_stmt> eof | eof
  List<Stmt> parse() {
    var statements = <Stmt>[];

    //ignores linebreaks here so it doesn't have to go all the way down the recursion to do it
    while (!_isAtEnd()) {
      if (match(TokenType.lineBreak)) continue;
      var declaration = _declaration();
      if (declaration != null) statements.add(declaration);
    }

    return statements;
  }

  ///<declaration> ::= <class_decl> | <rou_decl> | <var_decl_stmt> | <statement>
  Stmt _declaration() {
    try {
      if (match(TokenType.classToken)) return _classDeclaration();

      ///<rou_decl> ::= "routine" <routine>
      if (match(TokenType.routine)) return _routine("routine");
      if (match(TokenType.let)) return varDeclaration();
      return statement();
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
    var name = consume(TokenType.identifier, "Expect class name");

    //"<" <whitespace> <identifier>
    VariableExpr superclass;
    if (match(TokenType.less)) {
      consume(TokenType.identifier, "Expect superclass name");
      superclass = VariableExpr(previous());
    }

    //linebreaks after { dealt with by scanner
    consume(TokenType.leftBrace, "Expect '{' before class body");

    var methods = <RoutineStmt>[];

    //<routines> ::= routine <routines> | <whitespace_or_linebreak> <routines> ""
    while (!check(TokenType.rightBrace) && !_isAtEnd())
      if (check(TokenType.lineBreak)) {
        _advance();
      } else {
        methods.add(_routine("method"));
      }

    consume(TokenType.rightBrace, "Expect '}' after class body");

    return ClassStmt(name, superclass, methods);
  }

  ///kind is either 'routine' or 'method'
  ///<routine> ::= <identifier> <(> <parameters> <)> <whitespace_or_linebreak> <block>
  ///            | <identifier> <(> <)> <whitespace_or_linebreak> <block>
  RoutineStmt _routine(String kind) {
    var name = consume(TokenType.identifier, "Expect $kind name.");

    //linebreaks after this dealt with by scanner
    consume(TokenType.leftParentheses, "Expect '(' after $kind name;");

    var parameters = <Token>[];

    //<parameters> ::= <identifier> | <identifier> <whitespace> "," <whitespace_or_linebreak> <parameters>
    if (!check(TokenType.rightParentheses)) {
      do {
        if (match(TokenType.lineBreak)) continue;
        parameters.add(consume(TokenType.identifier, "Expect parameter name"));
      } while (match(TokenType.comma));
    }

    //possible linebreak here handled by the scanner
    consume(TokenType.rightParentheses, "Expect ')' after parameters.");

    match(TokenType.lineBreak);
    consume(TokenType.leftBrace, "Expect '{' after routine parameters");
    var body = _block();
    return RoutineStmt(name, parameters, body);
  }

  ///<var_decl_stmt> ::= <unterminated_var_decl_stmt> <delimitator>

  ///<unterminated_var_decl_stmt> ::= <let> <identifier>
  ///                               | <let> <identifier> <assigment_operator> <expression>
  ///                               | <let> <identifier> <(>  <)> <assigment_operator> <expression>
  ///                               | <let> <identifier> <(> <parameters> <)> <assigment_operator> <expression>
  ///<let> ::= "let" <whitespace>
  ///<assigment_operator> ::= <whitespace> "=" <whitespace_or_linebreak>
  @protected
  Stmt varDeclaration() {
    var name = consume(TokenType.identifier, "Expect variable name");

    List<Token> parameters;
    if (match(TokenType.leftParentheses)) {
      parameters = <Token>[];

      do {
        if (check(TokenType.rightParentheses)) break;
        //linebreaks after ( and , handled by scanner
        parameters.add(consume(TokenType.identifier, "Expect parameter name"));
      } while (match(TokenType.comma));

      //linebreaks right before ) handled by scanner

      consume(TokenType.rightParentheses, "Expect ')' after parameters.");
    }
    if (parameters?.isEmpty ?? true) parameters = null;

    Expr initializer;
    if (match(TokenType.assigment)) {
      //linebreak after = handled by scanner
      initializer = expression();
    }

    _consumeAny([TokenType.semicolon, TokenType.lineBreak],
        "Expect ';' or line break after variable declaration");
    return VarStmt(name, parameters, initializer);
  }

  ///<statement> ::= <expr_stmt> | <for_stmt> | <if_stmt> | <print_stmt> | <return_stmt> | <while_stmt> | <block> | <directive>
  @protected
  Stmt statement() {
    if (match(TokenType.forToken)) return forStatement();
    if (match(TokenType.ifToken)) return _ifStatement();
    if (match(TokenType.print)) return _printStatement();
    if (match(TokenType.returnToken)) return _returnStatement();
    if (match(TokenType.whileToken)) return _whileStatement();
    //might be an expression statement with a Set definition or a block
    if (match(TokenType.leftBrace)) return _parseLeftBrace();
    if (match(TokenType.hash)) return _directive();
    return expressionStatement();
  }

  ///<expr_stmt> ::= <expression> <delimitator>
  @protected
  Stmt expressionStatement() {
    var expr = expression();
    checkTerminator("expression");
    return ExpressionStmt(expr);
  }

  ///<for_stmt> ::= "for" <(> <for_stmt_init_clause> <whitespace> ";" <whitespace_or_linebreak> <for_stmt__clause> <whitespace> ";"
  ///               <whitespace_or_linebreak> <for_stmt__clause>  <)> <whitespace_or_linebreak> <statement>
  ///<for_stmt_init_clause> ::= <var_decl> | <expression> | ""
  ///<for_stmt__clause> ::= <expression> | ""
  @protected
  Stmt forStatement() {
    final token = previous();

    consume(TokenType.leftParentheses, "Expect '(' after 'for'.");

    //linebreaks after left parentheses handled by the parser

    Stmt initializer;

    //the initializer may be empty, a variable declaration or any other expression
    if (!match(TokenType.semicolon)) {
      if (match(TokenType.let)) {
        initializer = varDeclaration();
      } else {
        initializer = expressionStatement();
      }
    }

    //linebreaks after semicolons handled by the parser

    //The condition may be any expression, but may also be left empty
    var condition = (check(TokenType.semicolon)) ? null : expression();

    consume(TokenType.semicolon, "Expect ';' after loop condition.");

    //linebreaks after semicolons handled by the parser

    var increment = (check(TokenType.rightParentheses)) ? null : expression();

    //linebreaks before ) handled by scanner

    consume(TokenType.rightParentheses,
        "Expect ')' after increment in for statement");
    var body = statement();

    if (increment != null) {
      body = BlockStmt(<Stmt>[
        if (body is BlockStmt) ...body.statements,
        if (!(body is BlockStmt)) body,
        ExpressionStmt(increment)
      ]);
    }

    condition ??= LiteralExpr(true);

    body = WhileStmt(token, condition, body);

    if (initializer != null) body = BlockStmt([initializer, body]);

    return body;
  }

  ///<if_stmt> := <if_clause> | <if_clause> <whitespace_or_linebreak> <else_clause>
  ///<if_clause> ::= "if" <(> <expression> <)> <whitespace_or_linebreak> <statement>
  ///<else_clause> ::= "else" <whitespace_or_linebreak> <statement>
  Stmt _ifStatement() {
    consume(TokenType.leftParentheses, "Expect '(' after 'if'.");
    //linebreaks after left parentheses handled by the parser
    var condition = expression();

    //linebreak before ) handled by scanner

    consume(TokenType.rightParentheses, "Expect ')' after if condition.");

    match(TokenType.lineBreak);

    var thenBranch = statement();

    //linebreak before else handled by scanner

    var elseBranch = (match(TokenType.elseToken)) ? statement() : null;

    return IfStmt(condition, thenBranch, elseBranch);
  }

  ///<print_stmt> ::= <unterminated_print_stmt> <delimitator>
  ///<unterminated_print_stmt> ::= "print" <expression>
  Stmt _printStatement() {
    if (match(TokenType.lineBreak)) {
      _error(previous(),
          "linebreak right after 'print' keyword not allowed. Please start the target expression in the same line.");
    }
    var value = expression();
    checkTerminator("print");
    return PrintStmt(value);
  }

  ///<return_stmt> ::= "return" <whitespace> <expression> <whitespace> ";"
  ///                | "return" <whitespace> ";"
  ///                | "return" <whitespace> <expression> <whitespace> <linebreak>
  ///<unterminated_return_stmt> ::= "return" | "return" <whitespace> <expression>
  Stmt _returnStatement() {
    var keyword = previous();
    if (match(TokenType.lineBreak)) {
      _error(previous(),
          "linebreak not allowed immediately after return keyword! If you want to end the routine early, either write 'return null' or 'return;'");
    }
    var value = (check(TokenType.semicolon)) ? LiteralExpr(null) : expression();

    checkTerminator("return");

    return ReturnStmt(keyword, value);
  }

  ///<while_stmt> ::= "while" <(> <expression> <)> <statement>
  Stmt _whileStatement() {
    var token = previous();
    consume(TokenType.leftParentheses, "Expect '(' after 'while'.");

    //linebreak after left parentheses handled by parser

    var condition = expression();

    //linebreak before ) handled by scanner

    consume(TokenType.rightParentheses, "Expect ')' after while condition.");

    match(TokenType.lineBreak);

    var body = statement();

    return WhileStmt(token, condition, body);
  }

  ///<block> ::= <{> <block_body> <}> | <{> <block_body> <unterminated_optional_stmt> <}>
  ///<block_body> ::= <whitespace_or_linebreak> <block_body> | <statement> <block_body> | ""
  List<Stmt> _block() {
    //The left brace was already consumed in statement or _routine
    var statements = <Stmt>[];

    while (!check(TokenType.rightBrace) && !_isAtEnd()) {
      if (match(TokenType.lineBreak)) continue;
      statements.add(_declaration());
    }

    consume(TokenType.rightBrace, "Expect '}' after block.");

    return statements;
  }

  ///<expression> ::= <assigment>
  @protected
  Expr expression() {
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

    var expr = _or();

    if (match(TokenType.assigment)) {
      var equals = previous();
      //linebreaks here handled by scanner
      var value = _assigment();

      //This is why Grouping is considered a different type of expression: a = 1 is allowed, but (a) = 1 isn't.
      if (expr is VariableExpr) {
        var name = expr.name;
        return AssignExpr(name, value);
      } else if (expr is GetExpr) {
        return SetExpr(expr.object, expr.name, value);
      }

      _error(equals, "Invalid assigment target");
    }

    return expr;
  }

  ///<logic_or> ::= <logic_and> | <logic_and> <whitespace> "or" <whitespace_or_linebreak> <logic_or>
  Expr _or() {
    var expr = _and();

    while (match(TokenType.or)) {
      var op = previous();
      //linebreaks after 'or' keyword handled by scannner
      var right = _and();
      expr = LogicBinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///<logic_and> ::= <equality> | <equality> <whitespace> "and" <whitespace_or_linebreak> <logic_and>
  Expr _and() {
    var expr = _equality();

    while (match(TokenType.and)) {
      var op = previous();
      //linebreaks after 'and' keyword handled by scanner
      var right = _equality();
      expr = LogicBinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///<equality> ::= <comparison> | <comparison> <whitespace> <equality_operator> <whitespace_or_linebreak> <equality>
  ///<equality_operator> ::= "==" | "==="
  Expr _equality() {
    var expr = _comparison();

    while (matchAny([TokenType.equals, TokenType.identicallyEquals])) {
      var op = previous();
      //linebreaks after '==' operator handled by scanner
      var right = _comparison();
      expr = BinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///<comparison> ::= <set_binary> | <set_binary> <whitespace> <comparison_operator> <whitespace_or_linebreak> <comparison>
  ///<comparison_operator> ::= ">" | ">=" | "<" | "<="
  Expr _comparison() {
    //follows the pattern in _equality

    var expr = _setBinary();

    while (matchAny([
      TokenType.greater,
      TokenType.greaterEqual,
      TokenType.less,
      TokenType.lessEqual
    ])) {
      //linebreaks after the operators listed above handled by scanner
      expr = BinaryExpr(expr, previous(), _setBinary());
    }

    return expr;
  }

  ///<set_binary> ::= <addition> | <addition> <whitespace> <set_operator> <whitespace_or_linebreak> <set_binary>
  ///<set_operator> ::= "union" | "intersection" | "\" | "contained" | "disjoined" | "belongs"
  Expr _setBinary() {
    var expr = _addition();
    while (matchAny([
      TokenType.union,
      TokenType.intersection,
      TokenType.invertedSlash,
      TokenType.contained,
      TokenType.disjoined,
      TokenType.belongs
    ])) {
      //linebreaks after these tokens handled by the scanner
      expr = SetBinaryExpr(expr, previous(), _addition());
    }

    return expr;
  }

  ///<addition> ::= <multiplication> | <multiplication> <whitespace> <addition_operator> <whitespace_or_linebreak> <addition>
  ///<addition_operator> ::= "-" | "+"
  Expr _addition() {
    //follows the pattern in _equality

    var expr = _multiplication();

    while (matchAny([TokenType.minus, TokenType.plus])) {
      var op = previous();
      //linebreaks after the operators listed above handled by scanner
      var right = _multiplication();
      expr = BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///<multiplication> ::= <exponentiation> | <exponentiation> <whitespace> <multiplication_operator> <whitespace_or_linebreak> <multiplication>
  ///<multiplication_operator> ::= "*" | "/"
  Expr _multiplication() {
    //follows the pattern in _equality

    var expr = _exponentiation();

    while (matchAny([TokenType.slash, TokenType.star])) {
      var op = previous();
      //linebreaks after the operators listed above handled by scanner
      var right = _exponentiation();
      expr = BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///<exponentiation> ::= <unary_left> | <unary_left> <whitespace> "^" <whitespace_or_linebreak> <exponentiation>
  Expr _exponentiation() {
    //follows the pattern in _equality

    var expr = _unary_left();

    while (match(TokenType.exp)) {
      var op = previous();
      //linebreaks after '^' operator handled by scanner
      var right = _unary_left();
      expr = BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///<unary_left> ::= <unary_right> | <unary_left_operator> <whitespace_or_linebreak> <unary_left>
  ///<unary_left_operator> ::= "not" | "-" | "~"
  Expr _unary_left() {
    //this rule is a little different, and actually uses recursion. When you reach this rule, if you immediately find  '!', '-' or '~',
    //go back to the 'unary' rule

    if (matchAny([TokenType.minus, TokenType.not, TokenType.approx])) {
      var op = previous();
      //linebreaks after the operators listed above handled by scanner
      var right = _unary_left();
      return UnaryExpr(op, right);
    }

    //if it doesn't find any left-unary operators, looks for the right ones
    return _unary_right();
  }

  ///<unary_right> ::= <call> | <derivative> | <unary_right> <whitespace> <unary_right_operator>
  ///<unary_right_operator> ::= "!" | "'"
  Expr _unary_right() {
    var operand;
    //if it finds a 'del' token, parses a derivative
    if (match(TokenType.del)) {
      operand = _derivative();
    } else {
      //in any other case, go to the 'call' rule
      operand = _call();
    }
    //keeps composing it until it's done
    while (matchAny([TokenType.apostrophe, TokenType.factorial]))
      operand = UnaryExpr(previous(), operand);

    return operand;
  }

  ///<call> ::= <primary> <whitespace> <routine_or_field>
  ///<routine_or_field> ::= ""
  ///                     | <(> <)> <routine_or_field>
  ///                     | <(> <arguments> <)> <routine_or_field> |
  ///                     | "." <whitespace_or_linebreak> <identifier> <routine_or_field>
  Expr _call() {
    var expr = _primary();

    //if after a primary expression you find a parentheses, parses it as a function call, and keeps doing it until you don't find more parentheses
    //to allow for things like getFunction()();
    while (true) {
      if (match(TokenType.leftParentheses)) {
        //linebreak after ( handled by scanner
        expr = _finishCall(expr);
      } else if (match(TokenType.dot)) {
        //linebreak after . handled by scanner
        var name =
            consume(TokenType.identifier, "Expect property name after '.'");
        expr = GetExpr(expr, name);
      } else
        break;
    }

    return expr;
  }

  ///<arguments> ::= <expression> | <expression> <whitespace> "," <whitespace_or_linebreak> <arguments>
  Expr _finishCall(Expr callee) {
    var arguments = <Expr>[];
    //If you immediately find the ')' token, there are no arguments to the function call

    if (!check(TokenType.rightParentheses)) {
      //and if there are arguments, they are separeted by commas
      //do note that there is no max number of arguments. That might be a problem when (if) translating the interpreter to a lower level language.
      do {
        //linebreaks after '(' and ',' handled by scanner
        arguments.add(expression());
      } while (match(TokenType.comma));
    }

    //linebreak before ) handled by scanner

    var paren =
        consume(TokenType.rightParentheses, "Expect ')' after arguments.");

    return CallExpr(callee, paren, arguments);
  }

  ///<derivative> ::= <partial_differential> <whitespace> "/" <whitespace_or_linebreak> <derivative_parameters>
  ///<partial_differential> ::=  "del" <(> <expression> <)>
  ///<derivative_parameters> ::= "del" <(> <arguments> <)>
  Expr _derivative() {
    var keyword = consume(TokenType.leftParentheses,
        "Expect '(' after del keyword - linebreaks not allowed between 'del' and '('");
    //linebreaks after '(' handled by scanner
    var derivand = expression();
    //linebreak before ) handled by scanner
    consume(TokenType.rightParentheses, "Expect ')' after derivand");
    consume(TokenType.slash,
        "expect '/' after derivand - if you wanted to add a linebreak between ')' and '/', do it after the slash");
    //linebreaks after '/' handled by scanner
    consume(TokenType.del, "expect second 'del' after derivand");
    consume(TokenType.leftParentheses, "expect '(' after second del keyword");
    //linebreaks after '(' handled by scanner
    var variables = <Expr>[];
    if (check(TokenType.rightParentheses)) {
      _error(previous(),
          "at least one variable is necessary in derivative expression");
    }
    do {
      //linebreaks after '(' and ',' handled by scanner
      variables.add(expression());
    } while (match(TokenType.comma));

    //linebreaks before ')' handled by scanner

    consume(
        TokenType.rightParentheses, "expect ')' after derivative variables");

    return DerivativeExpr(keyword, derivand, variables);
  }

  /// <primary> ::= <set_definition> | number | string | "false" | "true" | "unknown" | "nil"
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
  @protected
  Expr _primary() {
    //since some tokens may both be sets and other types of syntax
    //(braces may be sets or blocks, parentheses may be groupings or intervals,
    //and one day square brackets may be index access/intervals and parentheses intervals/tuples)
    //we have to parse them assuming it can be either until we can be sure.

    //the "set" keyword MUST mean a set definition follows. If it doesn't, it's an error.
    if (match(TokenType.setToken)) return _setDefinition();

    //number | string
    if (matchAny([TokenType.number, TokenType.string])) {
      return LiteralExpr(previous().literal);
    }

    //false
    if (match(TokenType.falseToken)) {
      return LiteralExpr(bsFalse);
    }

    //true
    if (match(TokenType.trueToken)) {
      return LiteralExpr(bsTrue);
    }

    if (match(TokenType.unknown)) {
      return LiteralExpr(bsUnknown);
    }

    //nil
    if (match(TokenType.nil)) return LiteralExpr(null);

    //<(> <expression> <)>
    //or
    //<interval_definition> ::= <(> expression <whitespace> "," <whitespace_or_linebreak> expression <right_interval_edge>
    if (match(TokenType.leftParentheses)) return _parseLeftParentheses();

    //<roster_set_definition> ::= <{> <}> | <{> <arguments> <}>
    //or
    //<builder_set_definition> ::= <{> "|" <whitespace_or_linebreak> <logic_or> <}>
    //                           | <{> <arguments> <whitespace> "|" <whitespace_or_linebreak> <logic_or> <}>
    //or
    //just a block
    if (match(TokenType.leftBrace)) return _parseLeftBrace(true);

    //<interval_definition> ::= <[> expression <whitespace> "," <whitespace_or_linebreak> expression <right_interval_edge>
    if (match(TokenType.leftSquare)) return _parseLeftSquare();

    //identifier
    if (match(TokenType.identifier)) return VariableExpr(previous());
    if (match(TokenType.thisToken)) return ThisExpr(previous());

    //"super" <whitespace> "." <whitespace_or_linebreak> <identifier>
    if (match(TokenType.superToken)) {
      var keyword = previous();
      consume(TokenType.dot,
          "Expect '.' after 'super' - if you want to add a linebreak, do it after the dot");
      //linebreaks after '.' handled by scanner
      var method =
          consume(TokenType.identifier, "Expect superclass method name");
      return SuperExpr(keyword, method);
    }

    //if you get to this rule and don't find any of the above, you found a syntax error instead
    if (previous().type == TokenType.lineBreak &&
        checkAny([
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
    if (match(TokenType.leftParentheses)) return _parseLeftParentheses(true);
    if (match(TokenType.leftSquare)) return _parseLeftSquare(true);
    if (match(TokenType.leftBrace)) return _parseLeftBrace(true);
    throw _error(previous(), "Expecting Set definition after 'set' keyword");
  }

  ///<(> <expression> <)>
  ///or
  ///<interval_definition> ::= <(> expression <whitespace> "," <whitespace_or_linebreak> expression <right_interval_edge>
  Expr _parseLeftParentheses([bool mustBeSet = false]) {
    var _left = previous();
    //linebreaks after '(' handled by scanner
    var expr = expression();

    if (match(TokenType.comma)) {
      //in here we're sure that we're parsing an Interval
      var _expr = expression();
      //linebreaks before ']' and ')' handled by scanner
      _consumeAny([TokenType.rightBrace, TokenType.rightParentheses],
          "Expected ] or ) ending interval definition");
      return IntervalDefinitionExpr(_left, expr, _expr, previous());
    }
    if (mustBeSet) throw _error(previous(), "Expecting Interval definition");

    //linebreaks before ')' handled by scanner
    //if the ')' is not there, it's an error
    consume(TokenType.rightParentheses, "Expect ')' after expression");
    return GroupingExpr(expr);
  }

  ///<interval_definition> ::= <[> expression <whitespace> "," <whitespace_or_linebreak> expression <right_interval_edge>
  Expr _parseLeftSquare([bool mustBeSet = false]) {
    var left = previous();

    var expr = expression();

    consume(TokenType.comma, "Expecting comma in Interval definition");

    var _expr = expression();

    //linebreaks before ']' and ')' handled by scanner

    _consumeAny([TokenType.rightBrace, TokenType.rightParentheses],
        "Expected ] or ) ending interval definition");
    return IntervalDefinitionExpr(left, expr, _expr, previous());
  }

  ///rosterSetDefinition -> "{" linebreak? ( expression ("," linebreak? expression)*)? linebreak? "}"
  ///or
  ///builderSetDefinition -> "{" linebreak? (expression, ("," expression)* )? "|" linebreak? expression linebreak? "}"
  ///or
  ///block -> "{" (declaration | linebreak)* "}"
  Object _parseLeftBrace([bool expectSet = false]) {
    var _leftBrace = previous();
    Expr _setReturn;

    //{} -> empty set
    if (match(TokenType.rightBrace)) {
      if (expectSet) {
        return LiteralExpr(emptySet);
      } else {
        return ExpressionStmt(LiteralExpr(emptySet));
      }
    }

    //if we find a comma, we know it's a set definition
    //if we find a vertical bar, we know it's a builder set definition

    var expressions = <Expr>[];

    var first;

    if (!check(TokenType.verticalBar)) first = _declaration();

    //assumes it is a block

    var isSet = false;

    if (match(TokenType.comma)) {
      if (first == null) _error(previous(), "expect token before comma");
      if (first is ExpressionStmt) {
        expressions.add(first.expression);
      } else {
        _error(previous(),
            "all elements in a roster set definition must evaluate to a number");
      }
      isSet = true;
      do {
        //linebreaks after ','  handled by scanner
        expressions.add(expression());
      } while (match(TokenType.comma));
    }

    //is a builder set
    if (match(TokenType.verticalBar)) {
      if (first != null) {
        if (first is ExpressionStmt) {
          expressions.add(first.expression);
        } else {
          _error(previous(),
              "all parameters in a builder set definition must evaluate to a variable");
        }
      }

      var bar = previous();
      var logic = expression();
      //linebreak before } handled by scanner
      consume(TokenType.rightBrace, "Expect '}' after builder set definition");
      List<Token> parameters;
      if (expressions.isNotEmpty) {
        parameters = <Token>[];
        for (Expr parameter in expressions) {
          if (parameter is VariableExpr) {
            parameters.add(parameter.name);
          } else {
            throw SetDefinitionError("parameter is not explicit variable name");
          }
        }
      }

      _setReturn =
          BuilderDefinitionExpr(_leftBrace, parameters, logic, bar, previous());
    } else if (isSet) {
      //Roster set
      //linebreak before } handled by scanner
      consume(TokenType.rightBrace, "Expect '}' after roster set definition");

      _setReturn = RosterDefinitionExpr(_leftBrace, expressions, previous());
    }

    //if there is a single element, and it is a expression statement, assumes it's a RosterSet with a single element
    //if it isn't, assumes it is a block with a single
    if (match(TokenType.rightBrace)) {
      if (first is ExpressionStmt) {
        _setReturn =
            RosterDefinitionExpr(_leftBrace, [first.expression], previous());
      } else
        return BlockStmt([first]);
    }

    if (_setReturn != null) {
      if (expectSet)
        return _setReturn;
      else
        return ExpressionStmt(_setReturn);
    }

    var statements = <Stmt>[first];

    while (!check(TokenType.rightBrace) && !_isAtEnd()) {
      if (match(TokenType.lineBreak)) continue;
      statements.add(_declaration());
    }

    consume(TokenType.rightBrace, "Expect '}' after block.");
    return BlockStmt(statements);
  }
  //Helper function corner

  ///whether the current token's type is [type], consuming it if it is
  bool match(TokenType type) {
    if (check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  ///true if the current token matches any in [types], consuming it if it does
  bool matchAny(List<TokenType> types) {
    for (var type in types) {
      if (match(type)) return true;
    }
    return false;
  }

  ///whether the current token's type matches [type]
  @protected
  bool check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  ///[check] for many types
  @protected
  bool checkAny(List<TokenType> types) {
    if (_isAtEnd()) return false;
    return types.contains(_peek().type);
  }

  ///Goes to the next token, returning the current one. If already at the end, doesn't keep going
  ///(remember that, in theory, every list of tokens generated by BSScanner ends with an eof token)
  Token _advance() {
    if (!_isAtEnd()) _current++;
    return previous();
  }

  ///whether current token is the last one
  ///not adding the eof token would simply mean checking _current >= _tokens.length
  bool _isAtEnd() => _peek().type == TokenType.EOF;

  ///the current token without consuming it
  Token _peek() => _tokens[_current];

  ///return the token immediately before _current
  @protected
  Token previous() => _current > 0 ? _tokens[_current - 1] : null;

  ///checks if the current token matches [type] and consumes it.
  ///If it doesn't, causes an error
  @protected
  Token consume(TokenType type, String message) {
    if (check(type)) return _advance();

    //doesn't actually throw the error
    //So that it keeps parsing
    _error(_peek(), message);
    return null;
  }

  Token _consumeAny(List<TokenType> types, String message) {
    for (var type in types) {
      if (check(type)) return _advance();
    }

    _error(_peek(), message);
    return null;
  }

  ///Reports an error to the general interpreter and creates a [ParseError] without
  /// necessarily throwing it
  ParseError _error(Token token, String message) {
    _errorCallback(token, message);
    return ParseError();
  }

  ///When a syntax error is found, ignores the rest of the current expression by
  ///moving [_current] forward
  void _synchronize() {
    _advance();

    while (!_isAtEnd()) {
      if (previous().type == TokenType.semicolon) return;

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
  Stmt _directive() => DirectiveStmt(previous(), previous().literal);

  ///delimitator ::= <linebreak> | <;>
  void checkTerminator(String type) {
    //'}' and eof are unconsumed terminators to deal with the fact something at the end of a program or block might not have a linebreak,
    //which should work. ',' and '|' are unconsumed terminator as a crutch to make sure that they the first expression after an ambiguous
    //'{'. Since none of these are consumed, they will still cause an error when in the wrong place, so this isn't going to allow weird stuff
    //(i hope)
    if (checkAny([TokenType.semicolon, TokenType.lineBreak])) {
      _advance();
      return;
    }
    if (_isAtEnd() ||
        checkAny(
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
