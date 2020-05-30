
import 'BSInterpreter.dart';
import 'Token.dart';


//In essence, an Environment is the implementation of a scope.
class Environment {
  ///Stores variable names and values
  final Map<String, Object> _values = new Map();

  ///Represents the enclosing Environment (scope)
  final Environment enclosing;

  Environment([Environment this.enclosing = null]); 

  ///Defines a new variable. Note it doesn't check if it already exists, meaning variables can be redefined.
  void define(String name, Object value) => _values[name] = value;

  ///retrieves the value of a variable in the environment. If the variable isn't defined in this environment, looks for it in the enclosing ones. If it isn't in any scope up to global, causes a runtime error
  Object get(Token name) {
    if (_values.containsKey(name.lexeme)) return _values[name.lexeme];
    if (enclosing != null) return enclosing.get(name);
    throw new RuntimeError(name, "Undefined variable '" + name.lexeme + "'.");
  }

  ///Assigns a new value to a variable. If it isn't defined, causes a runtime error
  void assign(Token name, Object value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
    } else if (enclosing != null) enclosing.assign(name, value);
    else throw new RuntimeError(name, "Undefined variable '" + name.lexeme + "'.");
  }
}