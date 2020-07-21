import 'dart:collection' show HashMap;

import '../BSFunction/Number.dart';
import 'BetaScript.dart';
import 'Token.dart';

///Scans the source for tokens, returning a list of them on a call to scanTokens, the only public routine in this class.
class BSScanner {
  final String _source;
  final List<Token> _tokens = new List();
  HashMap<String, Function> _charToLexeme; //see _initializeMap

  //_start is the start of the lexeme currently being read, and _current the current value being processed.
  int _start;
  int _current;
  //If the source scanned is multiline, keeps the value of the current line for error reporting
  int _line;

  BSScanner(String this._source) {
    _start = 0;
    _current = 0;
    _line = 1;

    _initializeMap();
  }

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      _start = _current;
      _scanToken();
    }

    //if the last line of the file doesn`t end with a line break, it might come up as unterminated. To solve this, we add an extra linebreak token
    if (_tokens.last.type != TokenType.LINEBREAK)
      _tokens.add(new Token(TokenType.LINEBREAK, "\n", null, _line));
    //adds a end of file token in the end, although it isn't completely necessary
    _tokens.add(new Token(TokenType.EOF, "", null, _line));
    return _tokens;
  }

  bool _isAtEnd() => _current >= _source.length;

  ///initializes the map used to replace a big ugly switch-case block in _scanToken
  void _initializeMap() {
    _charToLexeme = HashMap.from({
      //these lexemes are always single character, and can be initialized with ease
      '(': () => _addToken(TokenType.LEFT_PARENTHESES),
      ')': () => _addToken(TokenType.RIGHT_PARENTHESES),
      '{': () => _addToken(TokenType.LEFT_BRACE),
      '}': () => _addToken(TokenType.RIGHT_BRACE),
      '[': () => _addToken(TokenType.LEFT_SQUARE),
      ']': () => _addToken(TokenType.RIGHT_SQUARE),
      ',': () => _addToken(TokenType.COMMA),
      '-': () => _addToken(TokenType.MINUS),
      '~': () => _addToken(TokenType.APPROX),
      '+': () => _addToken(TokenType.PLUS),
      ';': () => _addToken(TokenType.SEMICOLON),
      '*': () => _addToken(TokenType.STAR),
      '!': () => _addToken(TokenType.FACTORIAL),
      '^': () => _addToken(TokenType.EXP),
      //since things like .01 are valid numeric literals, '.' needs to be checked to be sure it's a dot or part of a literal.
      '.': () {
        if (_IsDigit(_peek()))
          _number();
        else
          _addToken(TokenType.DOT);
      },
      //for these, we need to check if they are followed by a '=' or not (since = and ==, < and <=, > and >= are different things)
      '=': () =>
          _addToken((_match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL)),
      '<': () =>
          _addToken((_match('=') ? TokenType.LESS_EQUAL : TokenType.LESS)),
      '>': () => _addToken(
          (_match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER)),
      //if the slash is followed by another slash, it's actually a comment, and the rest of the line should be ignored
      //TODO: add multiline comments
      '/': () {
        if (_match('/')) {
          while (_peek() != '\n' && !_isAtEnd()) _advance();
        } else
          _addToken(TokenType.SLASH);
      },
      //ignored, but increases the line counter.
      '\n': () {
        if (!_tokens.isEmpty) {
          TokenType last = _tokens.last.type;
          if (![
            TokenType.LEFT_PARENTHESES,
            TokenType.LEFT_BRACE,
            TokenType.LEFT_SQUARE,
            TokenType.COMMA,
            TokenType.DOT,
            TokenType.MINUS,
            TokenType.PLUS,
            TokenType.SEMICOLON,
            TokenType.LINEBREAK,
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
          ].contains(last)) _addToken(TokenType.LINEBREAK);
        }
        _line++;
      },
      //whitespace. Ignored.
      ' ': () {},
      '\r': () {},
      '\t': () {},
      //since the _string function takes no parameters, it can be passed directly.
      '"': _string,
    });
  }

  ///scans a single token.
  void _scanToken() {
    //gets the next character, consuming it (by moving _current forward)
    String c = _advance();

    //checks if it's one of the characters in _charToLexeme
    if (_charToLexeme.containsKey(c))
      _charToLexeme[c]();
    else {
      //if it isn't, it's either the start of a numeric literal, a identifier (or keyword), or an unexpected character.
      if (_IsDigit(c)) {
        _number();
      } else if (_isAlpha(c)) {
        _identifier();
      } else
        BetaScript.error(_line, "Error: Unexpected character " + c);
    }
  }

  ///returns the current character and moving forward to the next
  String _advance() {
    return _source[_current++];
  }

  ///a map containing keywords and the corresponding token type
  static const Map<String, TokenType> _keywords = {
    "and": TokenType.AND,
    "class": TokenType.CLASS,
    "del": TokenType.DEL,
    "else": TokenType.ELSE,
    "false": TokenType.FALSE,
    "for": TokenType.FOR,
    "if": TokenType.IF,
    "let": TokenType.LET,
    "nil": TokenType.NIL,
    "not": TokenType.NOT,
    "or": TokenType.OR,
    "print": TokenType.PRINT,
    "return": TokenType.RETURN,
    "routine": TokenType.ROUTINE,
    "super": TokenType.SUPER,
    "this": TokenType.THIS,
    "true": TokenType.TRUE,
    "while": TokenType.WHILE,
  };

  ///creates a new token, using the interval from _start to _current as the token's lexeme.
  void _addToken(TokenType type, [dynamic literal = null]) {
    String text = _source.substring(_start, _current);
    _tokens.add(new Token(type, text, literal, _line));
  }

  ///checks if the character at _current matches s (used mainly with multi-character operands). If it does, consumes it.
  bool _match(String s) {
    if (_isAtEnd()) return false;
    if (_source[_current] != s) return false;

    _current++;
    return true;
  }

  ///basically, _advance without actually advancing. Used to check if a literal or identifier has ended.
  String _peek() {
    if (_isAtEnd()) return null;
    return _source[_current];
  }

  ///having identified the beginning of a string literal, this function reads the rest of it.
  void _string() {
    while (_peek() != '"' && !_isAtEnd()) {
      //looks for the end of the literal
      if (_peek() == '\n') _line++;
      _advance();
    }

    //if the source ended without another '"' to close the string, causes an error.
    if (_isAtEnd())
      BetaScript.error(_line, "Unterminated String.");
    else {
      //if the string is properly formed, adds it to the token list, with the literal value having both '"' characters stripped off.
      _advance();
      String value = _source.substring(_start + 1, _current - 1);
      _addToken(TokenType.STRING, value);
    }
  }

  //https://stackoverflow.com/a/25886695
  //^ is the bitwise XOR operand for integers
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
    while (_IsDigit(_peek())) _advance();

    //if it reads a dot and after it more numbers, keeps going
    if (_peek() == '.' && _IsDigit(_peekNext())) {
      _advance();

      //consumes the rest of source after the dot.
      while (_IsDigit(_peek())) _advance();
    }

    _addToken(
        TokenType.NUMBER, n(double.parse(_source.substring(_start, _current))));
  }

  ///checks the character after current, returning null if it is after the end of the source.
  String _peekNext() {
    if (_current + 1 >= _source.length) return null;

    return _source.substring(_current + 1, _current + 2);
  }

  ///having found the start of a identifier, reads the rest of it and adds it to _tokens.
  void _identifier() {
    //keeps going while it finds numbers (even though it can't start with a number)
    while (_isAlphaNumeric(_peek())) _advance();

    String text = _source.substring(_start, _current);

    //if the identifier is a keyword, adds a token of the appropriate type.
    _addToken(
        (_keywords.containsKey(text)) ? _keywords[text] : TokenType.IDENTIFIER);
  }

  ///returns whether the character c is a underscore or a letter.
  static bool _isAlpha(String c) =>
      ((c?.length ?? 0) == 1) &&
      (c == "_" ||
          ("a".compareTo(c) <= 0 && "z".compareTo(c) >= 0) ||
          ("A".compareTo(c) <= 0 && "Z".compareTo(c) >= 0));

  ///returns true if the character c is a digit, letter or underscore
  static bool _isAlphaNumeric(String c) => _isAlpha(c) || _IsDigit(c);
}
