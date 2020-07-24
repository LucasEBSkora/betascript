import 'BSInterpreter.dart';
import 'BetaScript.dart';
import 'Expr.dart';
import 'Stmt.dart';
import 'Token.dart';

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

  ///This function is basically the program -> (declaration | linebreak)* EOF
  List<Stmt> parse() {
    List<Stmt> statements = new List();

    //ignores linebreaks here so it doesn't have to go all the way down the recursion to do it
    while (!_isAtEnd()) {
      if (_match(TokenType.LINEBREAK)) continue;
      var declaration = _declaration();
      if (declaration != null) statements.add(declaration);
    }

    return statements;
  }

  ///declaration -> classDecl | rouDecl | varDecl | statement
  Stmt _declaration() {
    try {
      if (_match(TokenType.CLASS)) return _classDeclaration();

      ///rouDecl -> "routine" routine
      if (_match(TokenType.ROUTINE)) return _routine("routine");
      if (_match(TokenType.LET)) return _varDeclaration();
      return _statement();
    } on ParseError {
      _synchronize();
      return null;
    }
  }

  ///classDecl -> "class" IDENTIFIER ( "<" IDENTIFIER)? "{" linebreak routine* linebreak "}"
  Stmt _classDeclaration() {
    Token name = _consume(TokenType.IDENTIFIER, "Expect class name");

    //( "<" IDENTIFIER)
    VariableExpr superclass = null;
    if (_match(TokenType.LESS)) {
      _consume(TokenType.IDENTIFIER, "Expect superclass name");
      superclass = new VariableExpr(_previous());
    }

    //linebreaks after { dealt with by scanner
    _consume(TokenType.LEFT_BRACE, "Expect '{' before class body");

    List<RoutineStmt> methods = new List();

    //and linebreaks between routines dealt with here
    while (!_check(TokenType.RIGHT_BRACE) && !_isAtEnd())
      if (_check(TokenType.LINEBREAK))
        _advance();
      else
        methods.add(_routine("method"));

    _consume(TokenType.RIGHT_BRACE, "Expect '}' after class body");

    return new ClassStmt(name, superclass, methods);
  }

  ///kind is either 'routine' or 'method'
  ///routine -> IDENTIFIER "(" linebreak? parameters? linebreak?")" linebreak? block
  RoutineStmt _routine(String kind) {
    Token name = _consume(TokenType.IDENTIFIER, "Expect $kind name.");

    //linebreaks after this dealt with by scanner
    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after $kind name;");

    List<Token> parameters = new List();

    ///parameters -> IDENTIFIER ( "," linebreak? IDENTIFIER)*
    if (!_check(TokenType.RIGHT_PARENTHESES)) {
      do {
        if (_match(TokenType.LINEBREAK)) continue;
        parameters.add(_consume(TokenType.IDENTIFIER, "Expect parameter name"));
      } while (_match(TokenType.COMMA));
    }

    _match(TokenType.LINEBREAK);

    _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after parameters.");
    _match(TokenType.LINEBREAK);
    _consume(TokenType.LEFT_BRACE, "Expect '{' after routine parameters");
    List<Stmt> body = _block();
    return new RoutineStmt(name, parameters, body);
  }

  ///varDecl -> "let" IDENTIFIER ("(" linebreak? parameters linebreak? ")")? ( "=" linebreak? expression)? delimitator
  Stmt _varDeclaration() {
    Token name = _consume(TokenType.IDENTIFIER, "Expect variable name");

    List<Token> parameters = null;
    if (_match(TokenType.LEFT_PARENTHESES)) {
      parameters = List();

      do {
        if (_check(TokenType.RIGHT_PARENTHESES)) break;
        if (_match(TokenType.LINEBREAK)) continue;
        parameters.add(_consume(TokenType.IDENTIFIER, "Expect parameter name"));
      } while (_match(TokenType.COMMA));

      _match(TokenType.LINEBREAK);

      _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after parameters.");
    }
    if (parameters?.isEmpty ?? true) parameters = null;

    Expr initializer = null;
    if (_match(TokenType.EQUAL)) {
      _match(TokenType.LINEBREAK);
      initializer = _expression();
    }

    _consumeAny([TokenType.SEMICOLON, TokenType.LINEBREAK],
        "Expect ';' or line break after variable declaration");
    return new VarStmt(name, parameters, initializer);
  }

  //statement -> exprStmt | forStmt | ifStmt | printStmt | returnStmt | whileStmt | block | directive
  Stmt _statement() {
    if (_match(TokenType.FOR)) return _forStatement();
    if (_match(TokenType.IF)) return _ifStatement();
    if (_match(TokenType.PRINT)) return _printStatement();
    if (_match(TokenType.RETURN)) return _returnStatement();
    if (_match(TokenType.WHILE)) return _whileStatement();
    if (_match(TokenType.LEFT_BRACE)) return BlockStmt(_block());
    if (_match(TokenType.HASH)) return _directive();
    return _expressionStatement();
  }

  ///exprStmt -> expression delimitator
  Stmt _expressionStatement() {
    Expr expr = _expression();
    _consumeAny([TokenType.SEMICOLON, TokenType.LINEBREAK],
        "Expect ';' or linebreak after value");
    return new ExpressionStmt(expr);
  }

  ///forStmt -> "for" "(" linebreak? (varDecl | exprStmt | ";") linebreak? expression? ";" linebreak? expression? linebreak? ")" linebreak statement
  Stmt _forStatement() {
    Token token = _previous();

    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after 'for'.");

    //linebreaks after left parentheses handled by the parser

    Stmt initializer;

    //the initializer may be empty, a variable declaration or any other expression
    if (_match(TokenType.SEMICOLON))
      initializer = null;
    else if (_match(TokenType.LET))
      initializer = _varDeclaration();
    else
      initializer = _expressionStatement();

    //linebreaks after semicolons handled by the parser

    //The condition may be any expression, but may also be left empty
    Expr condition = (_check(TokenType.SEMICOLON)) ? null : _expression();

    _consume(TokenType.SEMICOLON, "Expect ';' after loop condition.");

    //linebreaks after semicolons handled by the parser

    Expr increment =
        (_check(TokenType.RIGHT_PARENTHESES)) ? null : _expression();

    _match(TokenType.LINEBREAK);

    _consume(TokenType.RIGHT_PARENTHESES,
        "Expect ')' after increment in for statement");
    Stmt body = _statement();

    if (increment != null)
      body = new BlockStmt([body, new ExpressionStmt(increment)]);
    if (condition == null) condition = new LiteralExpr(true);

    body = new WhileStmt(token, condition, body);

    if (initializer != null) body = new BlockStmt([initializer, body]);

    return body;
  }

  ///ifStmt -> "if" "(" linebreak? expression linebreak? ")" linebreak? statement linebreak? ( "else" linebreak? statement)?
  Stmt _ifStatement() {
    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after 'if'.");
    //linebreaks after left parentheses handled by the parser
    Expr condition = _expression();

    _match(TokenType.LINEBREAK);

    _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after if condition.");

    _match(TokenType.LINEBREAK);

    Stmt thenBranch = _statement();

    _match(TokenType.LINEBREAK);

    Stmt elseBranch = (_match(TokenType.ELSE)) ? _statement() : null;

    return new IfStmt(condition, thenBranch, elseBranch);
  }

  ///printStmt -> "print" expression delimitator
  Stmt _printStatement() {
    if (_match(TokenType.LINEBREAK))
      _error(_previous(),
          "linebreak right after 'print' keyword not allowed. Please start the target expression in the same line.");
    Expr value = _expression();
    _consumeAny([TokenType.SEMICOLON, TokenType.LINEBREAK],
        "Expect ';' or linebreak after value");
    return new PrintStmt(value);
  }

  ///returnStmt -> "return" ((expression? ";") | (expression "\n"))
  Stmt _returnStatement() {
    Token keyword = _previous();
    if (_match(TokenType.LINEBREAK))
      _error(_previous(),
          "linebreak not allowed immediately after return keyword! If you want to end the routine early, either write 'return null' or 'return;'");
    Expr value =
        (_check(TokenType.SEMICOLON)) ? LiteralExpr(null) : _expression();

    _consumeAny([TokenType.SEMICOLON, TokenType.LINEBREAK],
        "Expect ';' or line break after return value");

    return new ReturnStmt(keyword, value);
  }

  ///whileStmt -> "while" "(" linebreak? expression linebreak? ")" linebreak statement
  Stmt _whileStatement() {
    Token token = _previous();
    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after 'while'.");

    //linebreak after left parentheses handled by parser

    Expr condition = _expression();

    _match(TokenType.LINEBREAK);

    _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after while condition.");

    _match(TokenType.LINEBREAK);

    Stmt body = _statement();

    return new WhileStmt(token, condition, body);
  }

  ///block -> "{" (declaration | linebreak)* "}"
  List<Stmt> _block() {
    //The left brace was already consumed in _statement or _routine
    List<Stmt> statements = new List();

    while (!_check(TokenType.RIGHT_BRACE) && !_isAtEnd()) {
      if (_match(TokenType.LINEBREAK)) continue;
      statements.add(_declaration());
    }

    _consume(TokenType.RIGHT_BRACE, "Expect '}' after block.");

    return statements;
  }

  ///expression -> assigment
  Expr _expression() {
    return _assigment();
  }

  ///assigment -> (( call ".")? linebreak? IDENTIFIER "=" linebreak? assigment) | logicOr
  Expr _assigment() {
    //Assigment is hard because when you get to the "=" token, you already consumed the identifier token
    //and if it is something more complex, mainly envolving objects, it may be necessary to go many tokens back to discover
    //what is the identifier
    //So what we must do is first assume it goes to another rule (logicOr) and store the value of this expression
    //and if we really have an assigment, transform the previously parsed result into a assigment target

    Expr expr = _or();

    if (_match(TokenType.EQUAL)) {
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

  ///logicOr -> logicAnd ( "or"  linebreak logicAnd)*
  Expr _or() {
    Expr expr = _and();

    while (_match(TokenType.OR)) {
      Token op = _previous();
      //linebreaks after 'or' keyword handled by scannner
      Expr right = _and();
      expr = new logicBinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///logicAnd -> equality ( "and"  linebreak equality)*
  Expr _and() {
    Expr expr = _equality();

    while (_match(TokenType.AND)) {
      Token op = _previous();
      //linebreaks after 'and' keyword handled by scanner
      Expr right = _equality();
      expr = new logicBinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///equality -> comparison ( "==" linebreak comparison )*
  Expr _equality() {
    Expr expr = _comparison();

    while (_match(TokenType.EQUAL_EQUAL)) {
      Token op = _previous();
      //linebreaks after '==' operator handled by scanner
      Expr right = _comparison();
      expr = new BinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///comparison -> addition ( (">" | ">=" | "<" | "<=") linebreak? addition)*
  Expr _comparison() {
    //follows the pattern in _equality

    Expr expr = _addition();

    while (_matchAny([
      TokenType.GREATER,
      TokenType.GREATER_EQUAL,
      TokenType.LESS,
      TokenType.LESS_EQUAL
    ])) {
      Token op = _previous();
      //linebreaks after the operators listed above handled by scanner
      Expr right = _addition();
      expr = new BinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///addition -> multiplication ( ("-" | "+") linebreak? multiplication)*
  Expr _addition() {
    //follows the pattern in _equality

    Expr expr = _multiplication();

    while (_matchAny([TokenType.MINUS, TokenType.PLUS])) {
      Token op = _previous();
      //linebreaks after the operators listed above handled by scanner
      Expr right = _multiplication();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///multiplication -> exponentiation ( ("*" | "/") linebreak? exponentiation)*
  Expr _multiplication() {
    //follows the pattern in _equality

    Expr expr = _exponentiation();

    while (_matchAny([TokenType.SLASH, TokenType.STAR])) {
      Token op = _previous();
      //linebreaks after the operators listed above handled by scanner
      Expr right = _exponentiation();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///exponentiation -> unary ("^" linebreak? unary)*
  Expr _exponentiation() {
    //follows the pattern in _equality

    Expr expr = _unary();

    while (_match(TokenType.EXP)) {
      Token op = _previous();
      //linebreaks after '^' operator handled by scanner
      Expr right = _unary();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///unary -> (( "!" | "not" | "-" | "~") linebreak?) unary | call | derivative
  Expr _unary() {
    //TODO: fix factorial, which is actually to the right of the operand

    //this rule is a little different, and actually uses recursion. When you reach this rule, if you immediately find  '!', '-' or '~',
    //go back to the 'unary' rule

    if (_matchAny([
      TokenType.MINUS,
      TokenType.FACTORIAL,
      TokenType.NOT,
      TokenType.APPROX
    ])) {
      Token op = _previous();
      //linebreaks after the operators listed above handled by scanner
      Expr right = _unary();
      return new UnaryExpr(op, right);
    }

    //if it finds a 'del' token, parses a derivative
    if (_match(TokenType.DEL)) return _derivative();

    //in any other case, go to the 'call' rule
    return _call();
  }

  ///call -> primary ( "(" linebreak? arguments? linebreak?")" | "." linebreak? IDENTIFIER)*
  ///arguments -> expression ( "," linebreak? expression )*
  Expr _call() {
    Expr expr = _primary();

    //if after a primary expression you find a parentheses, parses it as a function call, and keeps doing it until you don't find more parentheses
    //to allow for things like getFunction()();
    while (true) {
      if (_match(TokenType.LEFT_PARENTHESES)) {
        _match(TokenType.LINEBREAK);
        expr = _finishCall(expr);
      } else if (_match(TokenType.DOT)) {
        _match(TokenType.LINEBREAK);
        Token name =
            _consume(TokenType.IDENTIFIER, "Expect property name after '.'");
        expr = new GetExpr(expr, name);
      } else
        break;
    }

    return expr;
  }

  ///call -> primary ( "(" linebreak? arguments? linebreak?")" | "." linebreak? IDENTIFIER)*
  ///arguments -> expression ( "," linebreak? expression )*
  Expr _finishCall(Expr callee) {
    List<Expr> arguments = new List();
    //If you immediately find the ')' token, there are no arguments to the function call

    //linebreaks after '(' handled by scanner
    if (!_check(TokenType.RIGHT_PARENTHESES)) {
      //and if there are arguments, they are separeted by commas
      //do note that there is no max number of arguments. That might be a problem when (if) translating the interpreter to a lower level language.
      do {
        _match(TokenType.LINEBREAK);
        arguments.add(_expression());
      } while (_match(TokenType.COMMA));
    }

    _match(TokenType.LINEBREAK);

    Token paren =
        _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after arguments.");

    return new CallExpr(callee, paren, arguments);
  }

  ///derivative -> "del" "(" linebreak? expression linebreak?  ")" "/" linebreak?  "del" "(" linebreak?  arguments linebreak? ")"
  Expr _derivative() {
    Token keyword = _consume(TokenType.LEFT_PARENTHESES,
        "Expect '(' after del keyword - linebreaks not allowed between 'del' and '('");
    //linebreaks after '(' handled by scanner
    Expr derivand = _expression();
    _match(TokenType.LINEBREAK);
    _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after derivand");
    _consume(TokenType.SLASH,
        "expect '/' after derivand - if you wanted to add a linebreak between ')' and '/', do it after the slash");
    //linebreaks after '/' handled by scanner
    _consume(TokenType.DEL, "expect second 'del' after derivand");
    _consume(TokenType.LEFT_PARENTHESES, "expect '(' after second del keyword");
    //linebreaks after '(' handled by scanner
    List<Expr> variables = List();
    if (_check(TokenType.RIGHT_PARENTHESES))
      _error(_previous(),
          "at least one variable is necessary in derivative expression");
    do {
      _match(TokenType.LINEBREAK);
      variables.add(_expression());
    } while (_match(TokenType.COMMA));

    _match(TokenType.LINEBREAK);

    _consume(
        TokenType.RIGHT_PARENTHESES, "expect ')' after derivative variables");

    return new DerivativeExpr(keyword, derivand, variables);
  }

  ///primary -> NUMBER | STRING | "false" | "true" | "nil" | "(" linebreak? expression linebreak? ")" | IDENTIFIER | ("super" "." linebreak? IDENTIFIER)
  Expr _primary() {
    //NUMBER | STRING
    if (_matchAny([TokenType.NUMBER, TokenType.STRING]))
      return new LiteralExpr(_previous().literal);

    //false
    if (_match(TokenType.FALSE)) return new LiteralExpr(false);

    //true
    if (_match(TokenType.TRUE)) return new LiteralExpr(true);

    //nil
    if (_match(TokenType.NIL)) return new LiteralExpr(null);

    //"(" linebreak? expression linebreak? ")"
    if (_match(TokenType.LEFT_PARENTHESES)) {
      //linebreaks after '(' handled by scanner
      Expr expr = _expression();
      _match(TokenType.LINEBREAK);
      //if the ')' is not there, it's an error
      _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after expression");
      return new GroupingExpr(expr);
    }

    //IDENTIFIER
    if (_match(TokenType.IDENTIFIER)) return new VariableExpr(_previous());
    if (_match(TokenType.THIS)) return new ThisExpr(_previous());

    //("super" "." linebreak? IDENTIFIER)
    if (_match(TokenType.SUPER)) {
      Token keyword = _previous();
      _consume(TokenType.DOT,
          "Expect '.' after 'super' - if you want to add a linebreak, do it after the dot");
      //linebreaks after '.' handled by scanner
      Token method =
          _consume(TokenType.IDENTIFIER, "Expect superclass method name");
      return new SuperExpr(keyword, method);
    }

    //if you get to this rule and don't find any of the above, you found a syntax error instead
    if (_previous().type == TokenType.LINEBREAK &&
        _checkAny([
          TokenType.COMMA,
          TokenType.DOT,
          TokenType.MINUS,
          TokenType.PLUS,
          TokenType.SLASH,
          TokenType.STAR,
          TokenType.APPROX,
          TokenType.EXP,
          TokenType.EQUAL,
          TokenType.EQUAL_EQUAL,
          TokenType.GREATER,
          TokenType.GREATER_EQUAL,
          TokenType.LESS,
          TokenType.LESS_EQUAL,
          TokenType.AND,
          TokenType.OR,
          TokenType.NOT,
          TokenType.ELSE
        ]))
      throw _error(_peek(),
          "missing left argument for operator. If you wanted to break an expression into multiple lines, do it after operators");
    else
      throw _error(_peek(), "Expect expression.");
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
  ///(remember that, in theory, every list of tokens generated by BSScanner ends with an EOF token)
  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  ///returns whether current token is the last one
  ///not adding the EOF token would simply mean checking _current >= _tokens.length
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
      if (_previous().type == TokenType.SEMICOLON) return;

      switch (_peek().type) {
        case TokenType.CLASS:
        case TokenType.ROUTINE:
        case TokenType.LET:
        case TokenType.FOR:
        case TokenType.IF:
        case TokenType.WHILE:
        case TokenType.PRINT:
        case TokenType.RETURN:
          return;
        default:
      }

      _advance();
    }
  }

  Stmt _directive() {
    DirectiveStmt stmt = DirectiveStmt(_previous(), _previous().literal);
    //if the directive is global, it is set directly in the global directives
    //if they're local, the interpreter will deal with it in time
    if (!_interpreter.directives.setIfGlobal(stmt.directive, true)) {
      return stmt;
    } else
      return null;
  }
}
