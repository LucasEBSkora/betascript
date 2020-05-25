import '../BSCalculus/Number.dart';
import 'BetaScript.dart';
import 'Token.dart';

class BSScanner {
  final String _source;
  final List<Token> _tokens = new List();
  Map<String, Function> _charToLexeme;

  int _start;
  int _current;
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

    _tokens.add(new Token(TokenType.EOF, "", null, _line));
    return _tokens;
  }

  bool _isAtEnd() => _current >= _source.length;

  void _initializeMap() {
    _charToLexeme = {
      '(': () => _addToken(TokenType.LEFT_PARENTHESES),
      ')': () => _addToken(TokenType.RIGHT_PARENTHESES),
      '{': () => _addToken(TokenType.LEFT_BRACE),
      '}': () => _addToken(TokenType.RIGHT_BRACE),
      '[': () => _addToken(TokenType.LEFT_SQUARE),
      ']': () => _addToken(TokenType.RIGHT_SQUARE),
      ',': () => _addToken(TokenType.COMMA),
      '-': () => _addToken(TokenType.MINUS),
      '+': () => _addToken(TokenType.PLUS),
      ';': () => _addToken(TokenType.SEMICOLON),
      '*': () => _addToken(TokenType.STAR),
      '!': () => _addToken(TokenType.FACTORIAL),
      '.': () {
        if (_IsDigit(_peek()))
          _number();
        else
          _addToken(TokenType.DOT);
      },
      '=': () =>
          _addToken((_match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL)),
      '<': () =>
          _addToken((_match('=') ? TokenType.LESS_EQUAL : TokenType.LESS)),
      '>': () => _addToken(
          (_match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER)),
      '/': () {
        if (_match('/')) {
          while (_peek() != '\n' && !_isAtEnd()) _advance();
        } else
          _addToken(TokenType.SLASH);
      },
      ' ': () {},
      '\r': () {},
      '\t': () {},
      '\n': () {
        _line++;
      },
      '"': _string,
    };
  }

  void _scanToken() {
    String c = _advance();

    if (_charToLexeme.containsKey(c))
      _charToLexeme[c]();
    else {
      if (_IsDigit(c)) {
        _number();
      } else if (_isAlpha(c)) {
        _identifier();
      } else
        BetaScript.error(_line, "Error: Unexpected character " + c);
    }
  }

  String _advance() {
    return _source[_current++];
  }

  static const Map<String, TokenType> _keywords = {
    "and": TokenType.AND,
    "class": TokenType.CLASS,
    "else": TokenType.ELSE,
    "false": TokenType.FALSE,
    "function": TokenType.FUNCTION,
    "for": TokenType.FOR,
    "if": TokenType.IF,
    "nil": TokenType.NIL,
    "not": TokenType.NOT,
    "or": TokenType.OR,
    "print": TokenType.PRINT,
    "return": TokenType.RETURN,
    "super": TokenType.SUPER,
    "this": TokenType.THIS,
    "true": TokenType.TRUE,
    "var": TokenType.VAR,
    "while": TokenType.WHILE,
  };

  void _addToken(TokenType type, [dynamic literal = null]) {
    String text = _source.substring(_start, _current);
    _tokens.add(new Token(type, text, literal, _line));
  }

  bool _match(String s) {
    if (_isAtEnd()) return false;
    if (_source[_current] != s) return false;

    _current++;
    return true;
  }

  String _peek() {
    if (_isAtEnd()) return null;
    return _source[_current];
  }

  void _string() {
    while (_peek() != '"' && !_isAtEnd()) {
      if (_peek() == '\n') _line++;
      _advance();
    }

    if (_isAtEnd())
      BetaScript.error(_line, "Unterminated String.");
    else {
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
  static bool _IsDigit(String c) =>
      ((c?.length ?? 0) == 1) && ((c.codeUnitAt(0) ^ 0x30) <= 9);

  void _number() {
    while (_IsDigit(_peek())) _advance();

    if (_peek() == '.' && _IsDigit(_peekNext())) {
      _advance();

      while (_IsDigit(_peek())) _advance();
    }

    _addToken(
        TokenType.NUMBER, n(double.parse(_source.substring(_start, _current))));
  }

  String _peekNext() {
    if (_current + 1 >= _source.length) return null;

    return _source.substring(_current + 1, _current + 2);
  }

  void _identifier() {
    while (_isAlphaNumeric(_peek())) _advance();

    String text = _source.substring(_start, _current);

    TokenType type =
        (_keywords.containsKey(text)) ? _keywords[text] : TokenType.IDENTIFIER;
    _addToken(type);
  }

  static bool _isAlpha(String c) =>
      ((c?.length ?? 0) == 1) &&
      (c == "_" ||
          ("a".compareTo(c) <= 0 && "z".compareTo(c) >= 0) ||
          ("A".compareTo(c) <= 0 && "Z".compareTo(c) >= 0));

  static bool _isAlphaNumeric(String c) => _isAlpha(c) || _IsDigit(c);
}
