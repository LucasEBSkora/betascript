import 'dart:collection' show HashMap;

import 'token.dart';
import 'user_routine.dart';
import 'βs_class.dart';
import 'βs_interpreter.dart' show RuntimeError;

class BSInstance {
  final BSClass _class;
  final HashMap<String, Object> _fields = HashMap();

  BSInstance(this._class);

  @override
  String toString() => "${_class.name} instance";

  get(Token name) {
    if (_fields.containsKey(name.lexeme)) return _fields[name.lexeme];

    UserRoutine method = _class.findMethod(name.lexeme);
    if (method != null) return method.bind(this);

    throw RuntimeError(name, "Undefined property '${name.lexeme}'.");
  }

  void set(Token name, Object value) => _fields[name.lexeme] = value;
}
