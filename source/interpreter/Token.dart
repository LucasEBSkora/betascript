enum TokenType {
  LEFT_PARENTHESES, // (
  RIGHT_PARENTHESES, // )
  LEFT_BRACE, // {
  RIGHT_BRACE, // }
  LEFT_SQUARE, // [
  RIGHT_SQUARE, // ]
  COMMA, // ,
  DOT, // .
  MINUS, // -
  PLUS, // +
  SEMICOLON, // ;
  SLASH, // /
  STAR, // *
  FACTORIAL, // !
  APPROX, //~

  EQUAL, // =
  EQUAL_EQUAL, // ==
  GREATER, // >
  GREATER_EQUAL, // >=
  LESS, // <
  LESS_EQUAL, // <=

  IDENTIFIER,
  STRING, //String literals
  NUMBER, //Numeric literals (ints and floating-points)

  //reserved keywords (not all are actually going to be implemented)
  AND,
  CLASS,
  ELSE,
  FALSE,
  ROUTINE,
  FOR,
  IF,
  NIL,
  NOT,
  OR,
  PRINT,
  RETURN,
  SUPER,
  THIS,
  TRUE,
  LET,
  WHILE,

  EOF
}

class Token {
  final TokenType type;
  final String lexeme; //the source string that generated this lexeme
  final dynamic
      literal; //the literal value of the Token. Only initialized for NUMBER and STRING literals.
  final int line;

  Token(this.type, this.lexeme, this.literal, this.line);

  @override
  String toString() => "$type '$lexeme' $literal";
}
