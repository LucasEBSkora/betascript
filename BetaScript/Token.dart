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
  FUNCTION,
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
  VAR,
  WHILE,

  EOF

}

class Token {
  final TokenType type;
  final String lexeme;
  final dynamic literal;
  final int line;

  Token(this.type, this.lexeme, this.literal, this.line);
  
  String toString() => type.toString() + " " + lexeme.toString() + " " + literal.toString();


}
