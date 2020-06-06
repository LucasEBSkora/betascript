import 'BSClass.dart';
import 'Token.dart';
import 'BSInterpreter.dart' show RuntimeError;
import 'UserFunction.dart';

class BSInstance {
  final BSClass _class;
  final Map<String, Object> _fields = new Map();

  BSInstance(this._class);

  @override
  String toString() => "${_class.name} instance";

  get(Token name) {
    if (_fields.containsKey(name.lexeme))
      return _fields[name.lexeme];
    
    UserFunction method = _class.findMethod(name.lexeme);
    if (method != null) return method.bind(this);

    throw new RuntimeError(name, "Undefined property '${name.lexeme}."); 
  }

  void set(Token name, Object value) => _fields[name.lexeme] = value;
}