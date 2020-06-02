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

  /*The parser works by implementing the rules in the language's formal grammar, which, currently, are:

  program -> declaration* EOF

  declaration -> funDecl | varDecl | statement

  funDecl -> "function" function
  function -> IDENTIFIER "(" parameters? ")" block
  parameters -> IDENTIFIER ( "," IDENTIFIER)*

  varDecl -> "var" IDENTIFIER ( "=" expression): ";"

  statement -> exprStmt | forStmt | ifStmt | printStmt | whileStmt | block

  

  exprStmt -> expression ";"
  ifStmt -> "if" "(" expression ")" statement ( "else" statement)? 
  
  forStmt -> "for" "(" (varDecl | exprStmt | ";") expression? ";" expression? ")" statement
  
  printStmt -> "print" expression ";"
  whileStmt -> "while" "(" expression ")" statement
  block -> "{" declaration* "}"

  expression -> assigment

  assigment -> IDENTIFIER "=" assigment | logicOr

  logicOr -> logicAnd ( "or" logicAnd)*
  logicAnd -> equality ( "and" equality)*


  equality -> comparison ( "==" comparison )*
  comparison -> addition ( (">" | ">=" | "<" | "<=") addition)*
  addition -> multiplication ( ("-" | "+") multiplication)*
  multiplication -> unary ( ("*" | "/") unary)*
  unary -> ( "!" | "-") unary | call
  call -> primary ( "(" arguments? ")" )*
  arguments -> expression ( "," expression )*
  primary -> NUMBER | STRING | "false" | "true" | "nil" | "(" expression ") | IDENTIFIER" 
  
  these should be interpreted the following way: in order to build a valid BetaScript expression, one starts at the expression rule, and
  them follows the rule set in order to build it, going down.

  "expression -> equality" means "in order to build an expression, use the equality rule"

  equality -> comparison ( "==" comparison )* means "in order to build an equality, use a comparison rule followed by any number of '==' tokens followed by more comparisons"
  this also means equality is left-associative, which means that, in a chain of equalities, the left-most equality is evaluated first.

  a == b == c == d is evaluated as (((a == b) == c) == d) 

  looking at the wy the expression is written, one may think it's the other way around, but it is actually written that way to avoid recursion.
  In the recursive form, more intuitive, it reads as equality -> equality ("==" comparison)? (where ? means "may happen one or zero times"),
  and it is more apparent that the left-most operand is nested deeper, and thus evaluated first.

  The parse function simply follows the ruleset defined above, by calling methods which emulate each rule.

  Since evaluating a AST begins at the leaves, the lowest precedence rule is the one which is called first, so that they are nested upwards in the tree


  */

  ///This function is basically the program -> statement* EOF rule
  List<Stmt> parse() {
    List<Stmt> statements = new List();

    while (!_isAtEnd()) {
      statements.add(_declaration());
    }

    return statements;
  }

  ///declaration -> funDecl | varDecl | statement
  Stmt _declaration() {
    try {
      ///funDecl -> "function" function
      if (_matchSingle(TokenType.FUNCTION)) return _function("function");
      if (_matchSingle(TokenType.VAR)) return _varDeclaration();
      return _statement();
    } on ParseError {
      _synchronize();
      return null;
    }
  }

  ///kind is either 'function' or 'method'
  ///function -> IDENTIFIER "(" parameters? ")" block
  FunctionStmt _function(String kind) {
    Token name = _consume(TokenType.IDENTIFIER, "Expect $kind name.");

    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after $kind name;");

    List<Token> parameters = new List();

    ///parameters -> IDENTIFIER ( "," IDENTIFIER)*
    if (!_check(TokenType.RIGHT_PARENTHESES)) {
      do {
        parameters.add(_consume(TokenType.IDENTIFIER, "Expect parameter name"));
      } while (_matchSingle(TokenType.COMMA));
    }

    _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after parameters.");
    _consume(TokenType.LEFT_BRACE, "Expect '{' after function parameters");
    List<Stmt> body = _block();
    return new FunctionStmt(name, parameters, body);
  }

  ///varDecl -> "var" IDENTIFIER ( "=" expression): ";"
  Stmt _varDeclaration() {
    Token name = _consume(TokenType.IDENTIFIER, "Expect variable name");

    Expr initializer = null;
    if (_matchSingle(TokenType.EQUAL)) {
      initializer = _expression();
    }

    _consume(TokenType.SEMICOLON, "Expect ';' after variable declaration");
    return new VarStmt(name, initializer);
  }

  ///statement -> exprStmt | printStmt | block
  Stmt _statement() {
    if (_matchSingle(TokenType.FOR)) return _forStatement();
    if (_matchSingle(TokenType.PRINT)) return _printStatement();
    if (_matchSingle(TokenType.WHILE)) return _whileStatement();
    if (_matchSingle(TokenType.LEFT_BRACE)) return BlockStmt(_block());
    if (_matchSingle(TokenType.IF)) return _ifStatement();
    return _expressionStatement();
  }

  ///forStmt -> "for" "(" (varDecl | exprStmt | ";") expression? ";" expression? ")" statement
  Stmt _forStatement() {
    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after 'for'.");

    Stmt initializer;

    //the initializer may be empty, a variable declaration or any other expression
    if (_matchSingle(TokenType.SEMICOLON))
      initializer = null;
    else if (_matchSingle(TokenType.VAR))
      initializer = _varDeclaration();
    else
      initializer = _expressionStatement();

    //The condition may be any expression, but may also be left empty
    Expr condition = (_check(TokenType.SEMICOLON)) ? null : _expression();

    _consume(TokenType.SEMICOLON, "Expect ';' after loop condition.");

    Expr increment =
        (_check(TokenType.RIGHT_PARENTHESES)) ? null : _expression();

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
    //The left brace was already consumed in _statement or _function
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
    Stmt elseBranch = (_matchSingle(TokenType.ELSE)) ? _statement() : null;

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

    if (_matchSingle(TokenType.EQUAL)) {
      Token equals = _previous();
      Expr value = _assigment();

      //This is why Grouping is considered a different type of expression: a = 1 is allowed, but (a) = 1 isn't.
      if (expr is VariableExpr) {
        Token name = expr.name;
        return new AssignExpr(name, value);
      }

      _error(equals, "Invalid assigment target");
    }

    return expr;
  }

  ///logicOr -> logicAnd ( "or" logicAnd)*
  Expr _or() {
    Expr expr = _and();

    while (_matchSingle(TokenType.OR)) {
      Token op = _previous();
      Expr right = _and();
      expr = new logicBinaryExpr(expr, op, right);
    }

    return expr;
  }

  ///logicAnd -> equality ( "and" equality)*
  Expr _and() {
    Expr expr = _equality();

    while (_matchSingle(TokenType.AND)) {
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
    while (_matchSingle(TokenType.EQUAL_EQUAL)) {
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

  ///multiplication -> unary ( ("*" | "/") unary)*
  Expr _multiplication() {
    //follows the pattern in _equality

    Expr expr = _unary();

    while (_matchAny([TokenType.SLASH, TokenType.STAR])) {
      Token op = _previous();
      Expr right = _unary();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///unary -> ( "!" | "-") unary | call
  Expr _unary() {
    //TODO: fix factorial, which is actually to the right of the operand

    //this rule is a little different, and actually uses recursion. When you reach this rule, if you immediately find  '!' or '-',
    //go back to the 'unary' rule

    if (_matchAny([TokenType.MINUS, TokenType.FACTORIAL, TokenType.NOT])) {
      Token op = _previous();
      Expr right = _unary();
      return new UnaryExpr(op, right);
    }

    //in any other case, go to the 'primary' rule
    return _call();
  }

  ///call -> primary ( "(" arguments? ")" )*
  ///arguments -> expression ( "," expression )*
  Expr _call() {
    Expr expr = _primary();

    //if after a primary expression you find a parentheses, parses it as a function call, and keeps doing it until you don't find more parentheses
    //to allow for things like getFunction()();
    while (true) {
      if (_matchSingle(TokenType.LEFT_PARENTHESES))
        expr = _finishCall(expr);
      else
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
      } while (_matchSingle(TokenType.COMMA));
    }

    Token paren =
        _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after arguments.");

    return new CallExpr(callee, paren, arguments);
  }

  ///primary -> NUMBER | STRING | "false" | "true" | "nil" | "(" expression ") | IDENTIFIER"
  Expr _primary() {
    //false
    if (_matchSingle(TokenType.FALSE)) return new LiteralExpr(false);
    //true
    if (_matchSingle(TokenType.TRUE)) return new LiteralExpr(true);
    //nil
    if (_matchSingle(TokenType.NIL)) return new LiteralExpr(null);

    //NUMBER | STRING
    if (_matchAny([TokenType.NUMBER, TokenType.STRING]))
      return new LiteralExpr(_previous().literal);

    if (_matchSingle(TokenType.IDENTIFIER))
      return new VariableExpr(_previous());

    // "(" expression ")"
    if (_matchSingle(TokenType.LEFT_PARENTHESES)) {
      Expr expr = _expression();
      //if the ')' is not there, it's an error
      _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after expression");
      return new GroupingExpr(expr);
    }

    //if you get to this rule and don't find any of the above, you found a syntax error instead
    throw _error(_peek(), "Expect expression.");
  }

  //Helper function corner

  ///returns whether the current token's type is 'type', consuming it if it is
  bool _matchSingle(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  ///returns true if the current token matches any in 'types', consuming it if it does
  bool _matchAny(List<TokenType> types) {
    for (TokenType type in types) {
      if (_matchSingle(type)) return true;
    }
    return false;
  }

  ///returns whether the current token's type matches 'type'
  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  ///Goes to the next token, returning the current one. If already at the end, doesn't keep going (remember that, in theory, every list of tokens
  ///generated by BSScanner ends with an EOF token)
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
        case TokenType.FUNCTION:
        case TokenType.VAR:
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
