import 'dart:collection' show HashMap;

import 'user_routine.dart';
import 'βs_callable.dart';
import 'βs_instance.dart';
import 'βs_interpreter.dart';

class BSClass implements BSCallable {
  final String name;
  final BSClass _superclass;
  final HashMap<String, UserRoutine> _methods;

  const BSClass(this.name, this._superclass, this._methods);

  @override
  String toString() => name;

  @override

  ///if there is a constructor, the arity is the constructors arity.
  ///If there isn't, the arity is 0 (empty constructor)
  int get arity => (findMethod(name)?.arity ?? 0);

  @override
  Object callThing(BSInterpreter interpreter, List<Object> arguments) {
    //Crates a new instance
    var instance = BSInstance(this);
    //finds the constructor method
    var initializer = findMethod(name);
    //returns the constructor method bound to the empty instance so that 'this' is valid
    if (initializer != null) {
      initializer.bind(instance).callThing(interpreter, arguments);
    }
    return instance;
  }

  ///Looks for methods in the class, and them in the superclass
  UserRoutine findMethod(String name) {
    if (_methods.containsKey(name)) return _methods[name];
    if (_superclass != null) return _superclass.findMethod(name);
    return null;
  }
}
