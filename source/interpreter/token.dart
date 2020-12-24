enum TokenType {
  leftParentheses, // (
  rightParentheses, // )
  leftBrace, // {
  rightBrace, // }
  leftSquare, // [
  rightSquare, // ]
  comma, // ,
  dot, // .
  minus, // -
  plus, // +
  semicolon, // ;
  lineBreak, // '\n' - when the scanner isn't able to determine on it's own that a linebreak isn't relevant
  //mainly after the tokens detailed in diary entry 15/07/2020
  slash, // /
  invertedSlash, // \
  star, // *
  factorial, // !
  apostrophe, // '
  approx, // ~
  exp, // ^
  verticalBar, // |

  assigment, // = or :=
  equals, // == or =
  identicallyEquals, // === or ==
  greater, // >
  greaterEqual, // >=
  less, // <
  lessEqual, // <=

  identifier,
  string, //String literals
  number, //Numeric literals (ints and floating-points)

  hash, //# - used for directives

  //reserved keywords
  and,
  belongs,
  classToken,
  contained,
  del,
  disjoined,
  elseToken,
  falseToken,
  forToken,
  ifToken,
  intersection,
  let,
  nil,
  not,
  or,
  print,
  returnToken,
  routine,
  setToken,
  superToken,
  thisToken,
  trueToken,
  union,
  unknown,
  whileToken,

  EOF,

  //ONLY USED FOR FORMATTER SCANNER - see betascript-tools repository
  multilineComment,
  comment,
  wordComment
}

class Token {
  final TokenType type;
  //the source string that generated this lexeme
  final String lexeme;
  //the literal value of the Token. Only initialized for number and string literals.
  final Object literal;
  final int line;

  const Token(this.type, this.lexeme, this.literal, this.line);

  @override
  String toString() => "$type '$lexeme' ${literal != null ? literal : ""}";
}
