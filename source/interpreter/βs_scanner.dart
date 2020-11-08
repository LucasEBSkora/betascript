import 'dart:collection' show HashMap;

import 'token.dart';
import 'βscript.dart';
import '../βs_function/number.dart';

///Scans the source for tokens, returning a list of them on a call to scanTokens, the only public routine in this class.
class BSScanner {
  final String _source;
  final List<Token> _tokens = <Token>[];
  HashMap<String, Function> _charToLexeme; //see _initializeMap

  //_start is the start of the lexeme currently being read, and _current the current value being processed.
  int _start;
  int _current;
  //If the source scanned is multiline, keeps the value of the current line for error reporting
  int _line;

  BSScanner(this._source) {
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
    //adds a end of file token in the end, although it isn't completely necessary
    _tokens.add(new Token(TokenType.EOF, "", null, _line));
    return _removeLinebreaks(_tokens);
  }

  //many linebreaks can be removed looking at the next token, which means we have to wait until the scanner is finished to remove them
  static List<Token> _removeLinebreaks(List<Token> tokens) {
    for (int i = 0; i < tokens.length - 1;) {
      if (tokens[i].type == TokenType.lineBreak) {
        switch (tokens[i + 1].type) {
          case TokenType.rightBrace:
          case TokenType.rightParentheses:
          case TokenType.rightSquare:
          case TokenType.elseToken:
            tokens.removeAt(i);
            continue;
          default:
            ++i;
        }
      } else
        ++i;
    }
    return tokens;
  }

  bool _isAtEnd() => _current >= _source.length;

  ///initializes the map used to replace a big ugly switch-case block in _scanToken
  void _initializeMap() {
    _charToLexeme = HashMap.from({
      //these lexemes are always single character, and can be initialized with ease
      '(': () => _addToken(TokenType.leftParentheses),
      ')': () => _addToken(TokenType.rightParentheses),
      '{': () => _addToken(TokenType.leftBrace),
      '}': () => _addToken(TokenType.rightBrace),
      '[': () => _addToken(TokenType.leftSquare),
      ']': () => _addToken(TokenType.rightSquare),
      ',': () => _addToken(TokenType.comma),
      '-': () => _addToken(TokenType.minus),
      '~': () => _addToken(TokenType.approx),
      '+': () => _addToken(TokenType.plus),
      ';': () => _addToken(TokenType.semicolon),
      ';': () => _addToken(TokenType.semicolon), //greek question mark
      '*': () => _addToken(TokenType.star),
      '!': () => _addToken(TokenType.factorial),
      "'": () => _addToken(TokenType.apostrophe),
      '^': () => _addToken(TokenType.exp),
      '|': () => _addToken(TokenType.verticalBar),
      '@': () {
        //word comments ignore everything up to the next character of whitespace (but can be used normally inside strings)
        while (_peek() != '\n' &&
            _peek() != ' ' &&
            _peek() != '\r' &&
            _peek() != '\t' &&
            !_isAtEnd()) _advance();
      },
      '#': _directive,
      //since things like .01 are valid numeric literals, '.' needs to be checked to be sure it's a dot or part of a literal.
      '.': () {
        if (_IsDigit(_peek())) {
          _number();
        } else {
          _addToken(TokenType.dot);
        }
      },
      //for these, we need to check if they are followed by a '=' or not (since = and ==, < and <=, > and >= are different things)
      //specially '=', which can be '=', '==' or '==='
      '=': () => _addToken((_match('=')
          ? (_match('=') ? TokenType.identicallyEquals : TokenType.equals)
          : TokenType.assigment)),
      '<': () =>
          _addToken((_match('=') ? TokenType.lessEqual : TokenType.less)),
      '>': () =>
          _addToken((_match('=') ? TokenType.greaterEqual : TokenType.greater)),
      '/': () {
        //if the slash is followed by another slash, it's actually a comment, and the rest of the line should be ignored
        if (_match('/')) {
          while (_peek() != '\n' && !_isAtEnd()) _advance();
        }
        //if it's followed by a star, it's a multiline comment, and everything up to the next */ should be ignored
        else if (_match('*')) {
          while (!_match('*') || _peek() != '/') {
            if (_isAtEnd()) {
              BetaScript.error(_line, "unterminated multiline comment");
              break;
            }
            _advance();
          }
          //consumes those last  '*/' characters
          _advance();
          _advance();
        } else //in any other case we just have a normal slash
          _addToken(TokenType.slash);
      },
      '\\': () => _addToken(TokenType.invertedSlash),
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
          ].contains(last)) _addToken(TokenType.lineBreak);
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
    if (_charToLexeme.containsKey(c)) {
      _charToLexeme[c]();
    } else {
      //if it isn't, it's either the start of a numeric literal, a identifier (or keyword), or an unexpected character.
      if (_IsDigit(c)) {
        _number();
      } else if (_isValidCharacter(c)) {
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
  static HashMap<String, TokenType> _keywords = HashMap.from({
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
  });

  ///creates a new token, using the interval from _start to _current as the token's lexeme.
  void _addToken(TokenType type, [dynamic literal]) {
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
    if (_isAtEnd()) {
      BetaScript.error(_line, "Unterminated String.");
    } else {
      //if the string is properly formed, adds it to the token list, with the literal value having both '"' characters stripped off.
      _advance();
      String value = _source.substring(_start + 1, _current - 1);
      _addToken(TokenType.string, value);
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
    while (_IsDigit(_peek())) _advance();

    //if it reads a dot and after it more numbers, keeps going
    if (_peek() == '.' && _IsDigit(_peekNext())) {
      _advance();

      //consumes the rest of source after the dot.
      while (_IsDigit(_peek())) _advance();
    }

    _addToken(
        TokenType.number, n(double.parse(_source.substring(_start, _current))));
  }

  ///checks the character after current, returning null if it is after the end of the source.
  String _peekNext() {
    if (_current + 1 >= _source.length) return null;

    return _source.substring(_current + 1, _current + 2);
  }

  ///having found the start of a identifier, reads the rest of it and adds it to _tokens.
  void _identifier() {
    //keeps going while it finds numbers (even though it can't start with a number)
    while (!_isAtEnd() && _isExpandedAlphanumeric(_peek())) _advance();

    String text = _source.substring(_start, _current);

    //if the identifier is a keyword, adds a token of the appropriate type.
    _addToken(
        (_keywords.containsKey(text)) ? _keywords[text] : TokenType.identifier);
  }

  ///returns whether the character c is a underscore or a latin alphabet letter.
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

  static bool _isMathSymbol(String c) => false;

  //returns true if character is from the latin or greek alphabets, or if it is a valid mathematical symbol
  static bool _isValidCharacter(String c) =>
      _isAlpha(c) || _isGreek(c) || _isMathSymbol(c);

  ///returns true if the character c is a digit, from the latin or greek alphabets, or if it is a valid mathematical symbol
  static bool _isExpandedAlphanumeric(String c) =>
      _isValidCharacter(c) || _IsDigit(c);

  ///does the same as _identifier, but for directives, which are basically any string of characters ending in whitespace
  void _directive() {
    while (!_isWhitespace(_peek()) && !_isAtEnd()) _advance();
    _addToken(TokenType.hash, _source.substring(_start + 1, _current));
  }

  bool _isWhitespace(String c) =>
      c == '\n' || c == '\t' || c == '\r' || c == ' ';
}
