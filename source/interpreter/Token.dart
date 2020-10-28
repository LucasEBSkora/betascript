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
  LINEBREAK, // '\n' - when the scanner isn't able to determine on it's own that a linebreak isn't relevant
  //mainly after the tokens detailed in diary entry 15/07/2020
  SLASH, // /
  INVERTED_SLASH, // \
  STAR, // *
  FACTORIAL, // !
  APOSTROPHE, // '
  APPROX, // ~
  EXP, // ^
  VERTICAL_BAR, // |
  
  ASSIGMENT, // = or :=
  EQUALS, // == or =
  IDENTICALLY_EQUALS, // === or ==
  GREATER, // >
  GREATER_EQUAL, // >=
  LESS, // <
  LESS_EQUAL, // <=

  IDENTIFIER,
  STRING, //String literals
  NUMBER, //Numeric literals (ints and floating-points)

  HASH, //# - used for directives

  //reserved keywords
  AND,
  BELONGS,
  CLASS,
  CONTAINED,
  DEL,
  DISJOINED,
  ELSE,
  FALSE,
  FOR,
  IF,
  INTERSECTION,
  LET,
  NIL,
  NOT,
  OR,
  PRINT,
  RETURN,
  ROUTINE,
  SET,
  SUPER,
  THIS,
  TRUE,
  UNION,
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
