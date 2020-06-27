import 'BSCallable.dart';
import 'BSInstance.dart';
import 'BSInterpreter.dart';
import 'UserRoutine.dart';

class BSClass implements BSCallable {
  final String name;
  final BSClass _superclass;
  final Map<String, UserRoutine> _methods;

  BSClass(String this.name, BSClass this._superclass,
      Map<String, UserRoutine> this._methods);

  @override
  String toString() => name;

  @override
  int get arity => (findMethod(this.name)?.arity ??
      0); //if there is a constructor, the arity is the constructors arity. If there isn't, the arity is 0 (empty constructor)

  @override
  Object callThing(BSInterpreter interpreter, List<Object> arguments) {
    //Crates a new instance
    BSInstance instance = new BSInstance(this);
    //finds the constructor method
    UserRoutine initializer = findMethod(this.name);
    //returns the constructor method bound to the empty instance so that 'this' is valid
    if (initializer != null)
      initializer.bind(instance).callThing(interpreter, arguments);
    return instance;
  }

  ///Looks for methods in the class, and them in the superclass
  UserRoutine findMethod(String name) {
    if (_methods.containsKey(name)) return _methods[name];
    if (_superclass != null) return _superclass.findMethod(name);
    return null;
  }
}
