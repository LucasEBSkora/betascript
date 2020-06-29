import 'BetaScript.dart';
import 'Expr.dart';
import 'Stmt.dart';
import 'Token.dart';

class ParseError implements Exception {}

///The class that turns sequences of tokens into Abstract Syntax trees.
class BSParser {
  ///The list of tokens being parsed
  final List<Token> _tokens;

  //The token currently being parsed
  int _current;

  BSParser(List<Token> this._tokens) {
    _current = 0;
  }

  //The parser works by implementing the rules in the language's formal grammar,
  //which are described in 'formal grammar representation.txt'

  ///This function is basically the program -> statement* EOF rule
  List<Stmt> parse() {
    List<Stmt> statements = new List();

    while (!_isAtEnd()) {
      statements.add(_declaration());
    }

    return statements;
  }

  ///declaration -> classDecl | rou Decl | varDecl | statement
  Stmt _declaration() {
    try {
      if (_match(TokenType.CLASS)) return _classDeclaration();

      ///funDecl -> "routine" routine
      if (_match(TokenType.ROUTINE)) return _routine("routine");
      if (_match(TokenType.LET)) return _varDeclaration();
      return _statement();
    } on ParseError {
      _synchronize();
      return null;
    }
  }

  ///classDecl -> "class" IDENTIFIER ( "<" IDENTIFIER) "{" routine "}"
  Stmt _classDeclaration() {
    Token name = _consume(TokenType.IDENTIFIER, "Expect class name");

    //( "<" IDENTIFIER)
    VariableExpr superclass = null;
    if (_match(TokenType.LESS)) {
      _consume(TokenType.IDENTIFIER, "Expect superclass name.");
      superclass = new VariableExpr(_previous());
    }

    _consume(TokenType.LEFT_BRACE, "Expect '{' before class body");

    List<RoutineStmt> methods = new List();

    while (!_check(TokenType.RIGHT_BRACE) && !_isAtEnd())
      methods.add(_routine("method"));

    _consume(TokenType.RIGHT_BRACE, "Expect '}' after class body");

    return new ClassStmt(name, superclass, methods);
  }

  ///kind is either 'routine' or 'method'
  ///routine -> IDENTIFIER "(" parameters? ")" block
  RoutineStmt _routine(String kind) {
    Token name = _consume(TokenType.IDENTIFIER, "Expect $kind name.");

    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after $kind name;");

    List<Token> parameters = new List();

    ///parameters -> IDENTIFIER ( "," IDENTIFIER)*
    if (!_check(TokenType.RIGHT_PARENTHESES)) {
      do {
        parameters.add(_consume(TokenType.IDENTIFIER, "Expect parameter name"));
      } while (_match(TokenType.COMMA));
    }

    _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after parameters.");
    _consume(TokenType.LEFT_BRACE, "Expect '{' after routine parameters");
    List<Stmt> body = _block();
    return new RoutineStmt(name, parameters, body);
  }

  ///varDecl -> "let" IDENTIFIER ("(" parameters ")")? ( "=" expression)? ";"
  Stmt _varDeclaration() {
    Token name = _consume(TokenType.IDENTIFIER, "Expect variable name");

    List<Token> parameters = null;
    if (_match(TokenType.LEFT_PARENTHESES)) {
      parameters = List();
      do {
        if (_check(TokenType.RIGHT_PARENTHESES)) break;

        parameters.add(_consume(TokenType.IDENTIFIER, "Expect parameter name"));
      } while (_match(TokenType.COMMA));
      
      _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after parameters.");
    }

    Expr initializer = null;
    if (_match(TokenType.EQUAL)) initializer = _expression();

    _consume(TokenType.SEMICOLON, "Expect ';' after variable declaration");
    return new VarStmt(name, parameters, initializer);
  }

  //statement -> exprStmt | forStmt | ifStmt | printStmt | returnStmt | whileStmt | block
  Stmt _statement() {
    if (_match(TokenType.FOR)) return _forStatement();
    if (_match(TokenType.IF)) return _ifStatement();
    if (_match(TokenType.PRINT)) return _printStatement();
    if (_match(TokenType.RETURN)) return _returnStatement();
    if (_match(TokenType.WHILE)) return _whileStatement();
    if (_match(TokenType.LEFT_BRACE)) return BlockStmt(_block());
    return _expressionStatement();
  }

  ///forStmt -> "for" "(" (varDecl | exprStmt | ";") expression? ";" expression? ")" statement
  Stmt _forStatement() {
    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after 'for'.");

    Stmt initializer;

    //the initializer may be empty, a variable declaration or any other expression
    if (_match(TokenType.SEMICOLON))
      initializer = null;
    else if (_match(TokenType.LET))
      initializer = _varDeclaration();
    else
      initializer = _expressionStatement();

    //The condition may be any expression, but may also be left empty
    Expr condition = (_check(TokenType.SEMICOLON)) ? null : _expression();

    _consume(TokenType.SEMICOLON, "Expect ';' after loop condition.");

    Expr increment =
        (_check(TokenType.RIGHT_PARENTHESES)) ? null : _expression();

    _consume(TokenType.RIGHT_PARENTHESES,
        "Expect ')' after increment in for statement");
    Stmt body = _statement();

    if (increment != null)
      body = new BlockStmt([body, new ExpressionStmt(increment)]);
    if (condition == null) condition = new LiteralExpr(true);

    body = new WhileStmt(condition, body);

    if (initializer != null) body = new BlockStmt([initializer, body]);

    return body;
  }

  ///printStmt -> "print" expression ";"
  Stmt _printStatement() {
    Expr value = _expression();
    _consume(TokenType.SEMICOLON, "Expect ';' after value.");
    return new PrintStmt(value);
  }

  ///exprStmt -> expression ";"
  Stmt _expressionStatement() {
    Expr expr = _expression();
    _consume(TokenType.SEMICOLON, "Expect ';' after expression.");
    return new ExpressionStmt(expr);
  }

  ///block -> "{" declaration* "}"
  List<Stmt> _block() {
    //The left brace was already consumed in _statement or _routine
    List<Stmt> statements = new List();

    while (!_check(TokenType.RIGHT_BRACE) && !_isAtEnd())
      statements.add(_declaration());

    _consume(TokenType.RIGHT_BRACE, "Expect '}' after block.");

    return statements;
  }

  ///ifStmt -> "if" "(" expression ")" statement ( "else" statement)?
  Stmt _ifStatement() {
    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after 'if'.");
    Expr condition = _expression();
    _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after if condition.");

    Stmt thenBranch = _statement();
    Stmt elseBranch = (_match(TokenType.ELSE)) ? _statement() : null;

    return new IfStmt(condition, thenBranch, elseBranch);
  }

  ///whileStmt -> "while" "(" expression ")" statement
  Stmt _whileStatement() {
    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after 'if'.");
    Expr condition = _expression();
    _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after if condition.");

    Stmt body = _statement();

    return new WhileStmt(condition, body);
  }

  ///returnStmt -> "return" expression? ";"
  Stmt _returnStatement() {
    Token keyword = _previous();
    Expr value = (_check(TokenType.SEMICOLON)) ? null : _expression();
    _consume(TokenType.SEMICOLON, "Expect ';' after return value.");

    return new ReturnStmt(keyword, value);
  }

  ///expression -> assigment
  Expr _expression() {
    return _assigment();
  }

  ///assigment -> IDENTIFIER "=" assigment | equality
  Expr _assigment() {
    //Assigment is hard because when you get to the "=" token, you already consumed the identifier token
    //and if it is something more complex, mainly envolving objects, it may be necessary to go many tokens back to discover
    //what is the identifier
    //So what we must do is first assume it goes to another rule (equality) and store the value of this expression
    //and if we really have an assigment, transform the previously parsed result into a assigment target

    Expr expr = _or();

    if (_match(TokenType.EQUAL)) {
      Token equals = _previous();
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

  ///logicOr -> logicAnd ( "or" logicAnd)*
  Expr _or() {
    Expr expr = _and();

    while (_match(TokenType.OR)) {
      Token op = _previous();
      Expr right = _and();
      expr = new logicBinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///logicAnd -> equality ( "and" equality)*
  Expr _and() {
    Expr expr = _equality();

    while (_match(TokenType.AND)) {
      Token op = _previous();
      Expr right = _equality();
      expr = new logicBinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///equality -> comparison ( "==" comparison )*
  Expr _equality() {
    /// comparison
    Expr expr = _comparison();

    //( "==" comparison)* translates here to "as long as you find '==' tokens, keep adding more comparisons after them"
    while (_match(TokenType.EQUAL_EQUAL)) {
      Token op = _previous();
      Expr right = _comparison();
      expr = new BinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///comparison -> addition ( (">" | ">=" | "<" | "<=") addition)*
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

      Expr right = _addition();
      expr = new BinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///addition -> multiplication ( ("-" | "+") multiplication)*
  Expr _addition() {
    //follows the pattern in _equality

    Expr expr = _multiplication();

    while (_matchAny([TokenType.MINUS, TokenType.PLUS])) {
      Token op = _previous();
      Expr right = _multiplication();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///multiplication -> exponentiation ( ("*" | "/") exponentiation)*
  Expr _multiplication() {
    //follows the pattern in _equality

    Expr expr = _exponentiation();

    while (_matchAny([TokenType.SLASH, TokenType.STAR])) {
      Token op = _previous();
      Expr right = _exponentiation();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///exponentiation -> unary ("^" unary)*
  Expr _exponentiation() {
    //follows the pattern in _equality

    Expr expr = _unary();

    while (_match(TokenType.EXP)) {
      Token op = _previous();
      Expr right = _unary();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///unary -> ( "!" | "-" | "~") unary | call | derivative
  Expr _unary() {
    //TODO: fix factorial, which is actually to the right of the operand

    //this rule is a little different, and actually uses recursion. When you reach this rule, if you immediately find  '!', '-' or '~',
    //go back to the 'unary' rule

    if (_matchAny([TokenType.MINUS, TokenType.FACTORIAL, TokenType.NOT, TokenType.APPROX])) {
      Token op = _previous();
      Expr right = _unary();
      return new UnaryExpr(op, right);
    }

    //if it finds a 'del' token, parses a derivative
    if (_match(TokenType.DEL)) return _derivative();
    
    //in any other case, go to the 'call' rule
    return _call();
  }

  ///call -> primary ( "(" arguments? ")" | "." IDENTIFIER)*
  ///arguments -> expression ( "," expression )*
  Expr _call() {
    Expr expr = _primary();

    //if after a primary expression you find a parentheses, parses it as a function call, and keeps doing it until you don't find more parentheses
    //to allow for things like getFunction()();
    while (true) {
      if (_match(TokenType.LEFT_PARENTHESES))
        expr = _finishCall(expr);
      else if (_match(TokenType.DOT)) {
        Token name =
            _consume(TokenType.IDENTIFIER, "Expect property name after '.'");
        expr = new GetExpr(expr, name);
      } else
        break;
    }

    return expr;
  }

  ///call -> primary ( "(" arguments? ")" )*
  ///arguments -> expression ( "," expression )*
  Expr _finishCall(Expr callee) {
    List<Expr> arguments = new List();
    //If you immediately find the ')' token, there are no arguments to the function call
    if (!_check(TokenType.RIGHT_PARENTHESES)) {
      //and if there are arguments, they are separeted by commas
      //do note that there is no max number of arguments. That might be a problem when (if) translating the interpreter to a lower level language.
      do {
        arguments.add(_expression());
      } while (_match(TokenType.COMMA));
    }

    Token paren =
        _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after arguments.");

    return new CallExpr(callee, paren, arguments);
  }


  ///derivative -> "del" "(" expression ")" "/" "del" "(" arguments ")"
  Expr _derivative() {
    Token keyword = _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after del keyword");
    Expr derivand = _expression();    
    _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after derivand");
    _consume(TokenType.SLASH, "expect '/' after derivand");
    _consume(TokenType.DEL, "expect second 'del' after derivand");
    _consume(TokenType.LEFT_PARENTHESES, "expect '(' after second del keyword");
    List<Expr> variables = List();
    if (_check(TokenType.RIGHT_PARENTHESES)) _error(_previous(), "at least one variable is necessary in derivative expression");
    do {
      variables.add(_expression());
    } while(_match(TokenType.COMMA));

    _consume(TokenType.RIGHT_PARENTHESES, "expect ')' after derivative variables");

    return new DerivativeExpr(keyword, derivand, variables);
    
  }

  ///primary -> NUMBER | STRING | "false" | "true" | "nil" | "(" expression ") | IDENTIFIER | "super" "." IDENTIFIER
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

    // "(" expression ")"
    if (_match(TokenType.LEFT_PARENTHESES)) {
      Expr expr = _expression();
      //if the ')' is not there, it's an error
      _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after expression");
      return new GroupingExpr(expr);
    }

    //IDENTIFIER
    if (_match(TokenType.IDENTIFIER)) return new VariableExpr(_previous());
    if (_match(TokenType.THIS)) return new ThisExpr(_previous());

    //"super" "." IDENTIFIER
    if (_match(TokenType.SUPER)) {
      Token keyword = _previous();
      _consume(TokenType.DOT, "Expect '.' after 'super'");
      Token method =
          _consume(TokenType.IDENTIFIER, "Expect superclass method name");
      return new SuperExpr(keyword, method);
    }

    //if you get to this rule and don't find any of the above, you found a syntax error instead
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

  ///Goes to the next token, returning the current one. If already at the end, doesn't keep going
  ///(remember that, in theory, every list of tokens generated by BSScanner ends with an EOF token)
  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  //TODO: evaluate evidence against EOF token

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
    //TODO: maybe a bad idea
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
}
