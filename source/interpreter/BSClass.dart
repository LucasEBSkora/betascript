import 'BSCallable.dart';
import 'BSInstance.dart';
import 'BSInterpreter.dart';
import 'UserFunction.dart';

class BSClass implements BSCallable {
  final String name;
  final BSClass _superclass;
  final Map<String, UserFunction> _methods;

  BSClass(String this.name, BSClass this._superclass,
      Map<String, UserFunction> this._methods);

  @override
  String toString() => name;

  @override
  int get arity => (findMethod(this.name)?.arity ??
      0); //if there is a constructor, the arity is the constructors arity. If there isn't, the arity is 0 (empty constructor)

  @override
  Object call(BSInterpreter interpreter, List<Object> arguments) {
    //Crates a new instance
    BSInstance instance = new BSInstance(this);
    //finds the constructor method
    UserFunction initializer = findMethod(this.name);
    //returns the constructor method bound to the empty instance so that 'this' is valid
    if (initializer != null)
      initializer.bind(instance).call(interpreter, arguments);
    return instance;
  }

  ///Looks for methods in the class, and them in the superclass
  UserFunction findMethod(String name) {
    if (_methods.containsKey(name)) return _methods[name];
    if (_superclass != null) return _superclass.findMethod(name);
    return null;
  }
}
