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

  declaration -> varDecl | statement

  varDecl -> "var" IDENTIFIER ( "=" expression): ";"

  statement -> exprStmt | ifStmt | printStmt | whileStmt | block

  

  exprStmt -> expression ";"
  ifStmt -> "if" "(" expression ")" statement ( "else" statement)? 
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
  unary -> ( "!" | "-") unary | primary
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

  ///declaration -> varDecl | statement
  Stmt _declaration() {
    try {
      if (_match([TokenType.VAR])) return _varDeclaration();
      return _statement();
    } on ParseError {
      _synchronize();
      return null;
    }
  }

  ///varDecl -> "var" IDENTIFIER ( "=" expression): ";"
  Stmt _varDeclaration() {
    Token name = _consume(TokenType.IDENTIFIER, "Expect variable name");

    Expr initializer = null;
    if (_match([TokenType.EQUAL])) {
      initializer = _expression();
    }

    _consume(TokenType.SEMICOLON, "Expect ';' after variable declaration");
    return new VarStmt(name, initializer);
  }

  ///statement -> exprStmt | printStmt | block
  Stmt _statement() {
    if (_match([TokenType.PRINT])) return _printStatement();
    if (_match([TokenType.WHILE])) return _whileStatement();
    if (_match([TokenType.LEFT_BRACE])) return BlockStmt(_block());
    if (_match([TokenType.IF])) return _ifStatement();
    return _expressionStatement();
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
    //The left brace was already consumed in _statement
    List<Stmt> statements = new List();

    while (!_check(TokenType.RIGHT_BRACE) && !_isAtEnd())
      statements.add(_declaration());

    _consume(TokenType.RIGHT_BRACE, "Expect '}' after block.");

    return statements;
  }

  //ifStmt -> "if" "(" expression ")" statement ( "else" statement)? 
  Stmt _ifStatement() {
    _consume(TokenType.LEFT_PARENTHESES, "Expect '(' after 'if'.");
    Expr condition = _expression();
    _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after if condition.");

    Stmt thenBranch = _statement();
    Stmt elseBranch = (_match([TokenType.ELSE])) ? _statement() : null;

    return new IfStmt(condition, thenBranch, elseBranch);
  }

  //whileStmt -> "while" "(" expression ")" statement
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

    if (_match([TokenType.EQUAL])) {
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

  //logicOr -> logicAnd ( "or" logicAnd)*
  Expr _or() {
    Expr expr = _and();

    while (_match([TokenType.OR])) {
      Token op = _previous();
      Expr right = _and();
      expr = new logicBinaryExpr(expr, op, right);
    }

    return expr;
  }

  //logicAnd -> equality ( "and" equality)*
  Expr _and() {
    Expr expr = _equality();

    while (_match([TokenType.AND])) {
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
    while (_match([TokenType.EQUAL_EQUAL])) {
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

    while (_match([
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

    while (_match([TokenType.MINUS, TokenType.PLUS])) {
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

    while (_match([TokenType.SLASH, TokenType.STAR])) {
      Token op = _previous();
      Expr right = _unary();
      expr = new BinaryExpr(expr, op, right);
    }
    return expr;
  }

  ///unary -> ( "!" | "-") unary | primary
  Expr _unary() {
    //TODO: fix factorial, which is actually to the right of the operand

    //this rule is a little different, and actually uses recursion. When you reach this rule, if you immediately find  '!' or '-',
    //go back to the 'unary' rule

    if (_match([TokenType.MINUS, TokenType.FACTORIAL, TokenType.NOT])) {
      Token op = _previous();
      Expr right = _unary();
      return new UnaryExpr(op, right);
    }

    //in any other case, go to the 'primary' rule
    return _primary();
  }

  ///primary -> NUMBER | STRING | "false" | "true" | "nil" | "(" expression ")"
  Expr _primary() {
    //false
    if (_match([TokenType.FALSE])) return new LiteralExpr(false);
    //true
    if (_match([TokenType.TRUE])) return new LiteralExpr(true);
    //nil
    if (_match([TokenType.NIL])) return new LiteralExpr(null);

    //NUMBER | STRING
    if (_match([TokenType.NUMBER, TokenType.STRING]))
      return new LiteralExpr(_previous().literal);

    if (_match([TokenType.IDENTIFIER])) return new VariableExpr(_previous());

    // "(" expression ")"
    if (_match([TokenType.LEFT_PARENTHESES])) {
      Expr expr = _expression();
      //if the ')' is not there, it's an error
      _consume(TokenType.RIGHT_PARENTHESES, "Expect ')' after expression");
      return new GroupingExpr(expr);
    }

    //if you get to this rule and don't find any of the above, you found a syntax error instead
    throw _error(_peek(), "Expect expression.");
  }

  //Helper function corner

  ///returns whether the current token's type is contained in types, consuming it if it does
  bool _match(List<TokenType> types) {
    for (TokenType type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
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
  bool _isAtEnd() {
    return _peek().type == TokenType.EOF;
  }

  //returns the current token without consuming it
  Token _peek() {
    return _tokens[_current];
  }

  //return the token immediately before _current
  Token _previous() {
    return _tokens[_current - 1];
  }

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
