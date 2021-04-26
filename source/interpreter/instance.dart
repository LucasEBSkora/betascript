import 'dart:collection' show HashMap;

import 'token.dart';
import 'class.dart';
import 'interpreter.dart' show RuntimeError;

class BSInstance {
  final BSClass _class;
  final HashMap<String, Object?> _fields = HashMap<String, Object>();

  BSInstance(this._class);

  @override
  String toString() => "${_class.name} instance";

  Object get(Token name) {
    if (_fields.containsKey(name.lexeme)) return _fields[name.lexeme]!;

    var method = _class.findMethod(name.lexeme);
    if (method != null) return method.bind(this);

    throw RuntimeError(name, "Undefined property '${name.lexeme}'.");
  }

  void set(Token name, Object? value) => _fields[name.lexeme] = value;
}
