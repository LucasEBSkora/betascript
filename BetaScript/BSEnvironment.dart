
import 'BSInterpreter.dart';
import 'Token.dart';

class Environment {
  //Stores variable names and values
  final Map<String, Object> _values = new Map();

  ///Defines a new variable. Note it doesn't check if it already exists, meaning variables can be redefined.
  void define(String name, Object value) => _values[name] = value;

  Object get(Token name) {
    if (_values.containsKey(name.lexeme)) return _values[name.lexeme];
    throw new RuntimeError(name, "Undefined variable '" + name.lexeme + "'.");
  }
}