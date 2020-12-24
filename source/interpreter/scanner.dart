import 'dart:collection' show HashMap;

import 'package:meta/meta.dart';

import 'token.dart';
import '../function/number.dart';

///Scans the source for tokens, returning a list of them on a call to scanTokens, the only public routine in this class.
class BSScanner {
  @protected
  final String source;
  final List<Token> _tokens = <Token>[];
  @protected
  final Function errorCallback;
  @protected
  HashMap<String, void Function()> charToLexeme; //see _initializeMap

  ///[start] is the start of the lexeme currently being read
  @protected
  int start = 0;

  /// [current] is the current value being processed.
  @protected
  int current = 0;

  ///If the source scanned is multiline, keeps the value of the current line for error reporting
  @protected
  int line = 1;

  BSScanner(String this.source, Function this.errorCallback) {
    _initializeMap();
  }

  List<Token> scanTokens() {
    while (!isAtEnd()) {
      start = current;
      _scanToken();
    }

    //adds a end of file token in the end
    _tokens.add(Token(TokenType.EOF, "", null, line));
    _removeLinebreaks();
    return _tokens;
  }

  //many linebreaks can be removed looking at the next token,
  //which means we have to wait until the scanner is finished to remove them
  void _removeLinebreaks() {
    for (var i = 0; i < _tokens.length - 1;) {
      if (_tokens[i].type == TokenType.lineBreak) {
        switch (_tokens[i + 1].type) {
          case TokenType.rightBrace:
          case TokenType.rightParentheses:
          case TokenType.rightSquare:
          case TokenType.elseToken:
            _tokens.removeAt(i);
            continue;
          default:
            ++i;
        }
      } else
        ++i;
    }
  }

  @protected
  bool isAtEnd() => current >= source.length;

  ///initializes the map used to replace a big ugly switch-case block in [_scanToken]
  void _initializeMap() {
    charToLexeme = HashMap<String, void Function()>.from({
      //these lexemes are always single character, and can be initialized with ease
      '(': () => addToken(TokenType.leftParentheses),
      ')': () => addToken(TokenType.rightParentheses),
      '{': () => addToken(TokenType.leftBrace),
      '}': () => addToken(TokenType.rightBrace),
      '[': () => addToken(TokenType.leftSquare),
      ']': () => addToken(TokenType.rightSquare),
      ',': () => addToken(TokenType.comma),
      '-': () => addToken(TokenType.minus),
      '~': () => addToken(TokenType.approx),
      '+': () => addToken(TokenType.plus),
      ';': () => addToken(TokenType.semicolon),
      ';': () => addToken(TokenType.semicolon), //greek question mark
      '*': () => addToken(TokenType.star),
      '!': () => addToken(TokenType.factorial),
      "'": () => addToken(TokenType.apostrophe),
      '^': () => addToken(TokenType.exp),
      '|': () => addToken(TokenType.verticalBar),
      '@': () {
        //word comments ignore everything up to the next character of whitespace (but can be used normally inside strings)
        while (peek() != '\n' &&
            peek() != ' ' &&
            peek() != '\r' &&
            peek() != '\t' &&
            !isAtEnd()) advance();
      },
      '#': _directive,
      //since things like .01 are valid numeric literals, '.' needs to be checked to be sure it's a dot or part of a literal.
      '.': () {
        if (_IsDigit(peek())) {
          _number();
        } else {
          addToken(TokenType.dot);
        }
      },
      //for these, we need to check if they are followed by a '=' or not (since = and ==, < and <=, > and >= are different things)
      //specially '=', which can be '=', '==' or '==='
      '=': () => addToken((match('=')
          ? (match('=') ? TokenType.identicallyEquals : TokenType.equals)
          : TokenType.assigment)),
      '<': () => addToken((match('=') ? TokenType.lessEqual : TokenType.less)),
      '>': () =>
          addToken((match('=') ? TokenType.greaterEqual : TokenType.greater)),
      '/': () {
        //if the slash is followed by another slash, it's actually a comment, and the rest of the line should be ignored
        if (match('/')) {
          while (peek() != '\n' && !isAtEnd()) advance();
        }
        //if it's followed by a star, it's a multiline comment, and everything up to the next */ should be ignored
        else if (match('*')) {
          while (!match('*') || peek() != '/') {
            if (isAtEnd()) {
              errorCallback(line, "unterminated multiline comment");
              break;
            }
            advance();
          }
          //consumes those last  '*/' characters
          advance();
          advance();
        } else //in any other case we just have a normal slash
          addToken(TokenType.slash);
      },
      '\\': () => addToken(TokenType.invertedSlash),
      //sometimes can be ignored, sometimes used as delimitator, but always increases the line counter.
      '\n': () {
        if (!_tokens.isEmpty) {
          TokenType last = _tokens.last.type;
          if (![
            TokenType.leftParentheses, //(
            TokenType.leftBrace, // [
            TokenType.leftSquare, // {
            TokenType.comma, // ,
            TokenType.dot, // .
            TokenType.minus, // -
            TokenType.plus, // +
            TokenType.semicolon, // ;
            TokenType.lineBreak, //
            TokenType.slash, // /
            TokenType.star, // *
            TokenType.approx, // ~
            TokenType.exp, // ^
            TokenType.verticalBar, // |
            TokenType.assigment, // =
            TokenType.equals, // ==
            TokenType.identicallyEquals, // ===
            TokenType.greater, // >
            TokenType.greaterEqual, // >=
            TokenType.less, // <
            TokenType.lessEqual, // <=
            TokenType.and, // and
            TokenType.or, // or
            TokenType.not, // not
            TokenType.elseToken, // else
            TokenType.contained, // contained
            TokenType.disjoined, // disjoined
            TokenType.setToken, // set
            TokenType.union, // union
            TokenType.intersection, // intersection
          ].contains(last)) addToken(TokenType.lineBreak);
        }
        line++;
      },
      //whitespace. Ignored.
      ' ': () {},
      '\r': () {},
      '\t': () {},
      //since the _string function takes no parameters, it can be passed directly.
      '"': _string,
      //unicode variants for math operations
      '¬': () => addToken(TokenType.not),
      '⊂': () => addToken(TokenType.contained),
      '∈': () => addToken(TokenType.belongs),
      '∪': () => addToken(TokenType.union),
      '∩': () => addToken(TokenType.intersection),
      '∧': () => addToken(TokenType.and),
      '∨': () => addToken(TokenType.or),
      '∂': () => addToken(TokenType.del),
      '≡': () => addToken(TokenType.identicallyEquals),
    });
  }

  ///scans a single [Token].
  void _scanToken() {
    //gets the next character, consuming it (by moving current forward)
    final c = advance();

    //checks if it's one of the characters in charToLexeme
    if (charToLexeme.containsKey(c)) {
      charToLexeme[c]();
    } else {
      //if it isn't, it's either the start of a numeric literal, a identifier (or keyword), or an unexpected character.
      if (_IsDigit(c)) {
        _number();
      } else if (_isValidCharacter(c)) {
        _identifier();
      } else
        errorCallback(line, "Error: Unexpected character " + c);
    }
  }

  ///returns the current character and moving forward to the next
  @protected
  String advance() {
    return source[current++];
  }

  ///a map containing keywords and the corresponding token type
  static const Map<String, TokenType> _keywords = {
    "and": TokenType.and,
    "belongs": TokenType.belongs,
    "class": TokenType.classToken,
    "contained": TokenType.contained,
    "del": TokenType.del,
    "disjoined": TokenType.disjoined,
    "else": TokenType.elseToken,
    "false": TokenType.falseToken,
    "for": TokenType.forToken,
    "if": TokenType.ifToken,
    "intersection": TokenType.intersection,
    "let": TokenType.let,
    "nil": TokenType.nil,
    "not": TokenType.not,
    "or": TokenType.or,
    "print": TokenType.print,
    "return": TokenType.returnToken,
    "routine": TokenType.routine,
    "set": TokenType.setToken,
    "super": TokenType.superToken,
    "this": TokenType.thisToken,
    "true": TokenType.trueToken,
    "while": TokenType.whileToken,
    "union": TokenType.union,
    "unknown": TokenType.unknown,
  };

  ///creates a new [Token], using the interval from [start] to [current] as the token's lexeme.
  @protected
  void addToken(TokenType type, [Object literal]) {
    var text = source.substring(start, current);
    _tokens.add(Token(type, text, literal, line));
  }

  ///checks if the character at [current] matches [s]
  ///(used mainly with multi-character operands). If it does, consumes it.
  @protected
  bool match(String s) {
    if (isAtEnd()) return false;
    if (source[current] != s) return false;

    current++;
    return true;
  }

  ///basically, [advance] without actually advancing.
  ///Used to check if a literal or identifier has ended.
  @protected
  String peek() => (isAtEnd()) ? null : source[current];

  ///having identified the beginning of a string literal,
  ///this function reads the rest of it.
  void _string() {
    while (peek() != '"' && !isAtEnd()) {
      //looks for the end of the literal
      if (peek() == '\n') line++;
      advance();
    }

    //if the source ended without another '"' to close the string, causes an error.
    if (isAtEnd()) {
      errorCallback(line, "Unterminated String.");
    } else {
      //if the string is properly formed, adds it to the token list, with the literal value having both '"' characters stripped off.
      advance();
      var value = source.substring(start + 1, current - 1);
      addToken(TokenType.string, value);
    }
  }

  //https://stackoverflow.com/a/25886695
  //^ is the bitwise Xor operand for integers
  //since 0 to 9 are 0x30 to 0x39 in UTF-16 where 0x30 is 0b110000 and 0x39 is 111001
  //any value that doesn't have both bites in 0x30 set to true will have the other set
  //to true, becoming bigger than nine
  //if it has any bit to the right of the sixth set to true, the number is already bigger than nine
  //and if it has no digits to the right of the sixth set to true
  //but it does have the sixth and fifth set to true, it will only pass the check
  //if the result is smaller or equal to 0b1001, which is, again 0x39
  //if the string passed is null or has a different length than 1, returns false

  ///checks if a character is a digit (0 to 9)
  static bool _IsDigit(String c) =>
      ((c?.length ?? 0) == 1) && ((c.codeUnitAt(0) ^ 0x30) <= 9);

  ///having found the start of a numeric literal, reads the rest of it and adds it to _tokens.
  void _number() {
    //keeps going while only reading numbers
    while (_IsDigit(peek())) advance();

    //if it reads a dot and after it more numbers, keeps going
    if (peek() == '.' && _IsDigit(peekNext())) {
      advance();

      //consumes the rest of source after the dot.
      while (_IsDigit(peek())) advance();
    }

    addToken(
        TokenType.number, n(double.parse(source.substring(start, current))));
  }

  ///checks the character after current, returning null if it is after the end of the source.
  String peekNext() => (current + 1 >= source.length)
      ? null
      : source.substring(current + 1, current + 2);

  ///having found the start of a identifier, reads the rest of it and adds it to [_tokens].
  void _identifier() {
    //keeps going while it finds numbers (even though it can't start with a number)
    while (!isAtEnd() && _isExpandedAlphanumeric(peek())) advance();

    var text = source.substring(start, current);

    //if the identifier is a keyword, adds a token of the appropriate type.
    addToken(
        (_keywords.containsKey(text)) ? _keywords[text] : TokenType.identifier);
  }

  ///whether the character [c] is a underscore or a latin alphabet letter.
  static bool _isAlpha(String c) =>
      ((c?.length ?? 0) == 1) &&
      (c == "_" ||
          ("a".compareTo(c) <= 0 && "z".compareTo(c) >= 0) ||
          ("A".compareTo(c) <= 0 && "Z".compareTo(c) >= 0));

  //as per https://stackoverflow.com/a/47956543/14011990
  static bool _isGreek(String c) {
    final int asUnicode = c.runes.single;
    return (0x391 <= asUnicode && asUnicode <= 0x3a9) || //Greek capitals
        (0x3B1 <= asUnicode && asUnicode <= 0x3c9); //Grek small
  }

  ///returns true if [c] is from the latin or greek alphabets
  static bool _isValidCharacter(String c) => _isAlpha(c) || _isGreek(c);

  ///true if [c] is a digit, from the latin or greek alphabets,
  ///or if it is a valid mathematical symbol
  static bool _isExpandedAlphanumeric(String c) =>
      _isValidCharacter(c) || _IsDigit(c);

  ///does the same as [_identifier], but for directives,
  ///which are basically any string of characters ending in whitespace
  void _directive() {
    while (!_isWhitespace(peek()) && !isAtEnd()) advance();
    addToken(TokenType.hash, source.substring(start + 1, current));
  }

  bool _isWhitespace(String c) =>
      c == '\n' || c == '\t' || c == '\r' || c == ' ';
}
