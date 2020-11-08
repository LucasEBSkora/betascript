import 'stmt.dart';
import 'βs_callable.dart';
import 'βs_environment.dart';
import 'βs_instance.dart';
import 'βs_interpreter.dart';

class UserRoutine implements BSCallable {
  final RoutineStmt _declaration;
  final Environment _closure;
  final bool _isInitializer;

  const UserRoutine(this._declaration, this._closure, this._isInitializer);

  @override
  int get arity => _declaration.parameters.length;

  @override
  Object callThing(BSInterpreter interpreter, List<Object> arguments) {
    //Creates routine scope
    var environment = Environment(_closure);

    //defines and initializes parameters in routine scope

    //Assumes it is safe to iterate in both lists because arity was checked in Interpreter.VisitCallExpr
    for (var i = 0; i < _declaration.parameters.length; ++i)
      environment.define(_declaration.parameters[i].lexeme, arguments[i]);

    //executes block
    //using exceptions as a way to exit the routine and return here, with the proper return value
    try {
      interpreter.executeBlock(_declaration.body, environment);
    } on Return catch (r) {
      if (_isInitializer) return _closure.getAt(0, "this");
      return r.value;
    }

    //if the routine is a constructor, returns 'this' regardless of return statements inside it
    return (_isInitializer) ? _closure.getAt(0, "this") : null;
  }

  @override
  String toString() => "<fn ${_declaration.name.lexeme}>";

  ///Creates a new scope for the method copying the old one and includes the "variable" 'this' in it
  UserRoutine bind(BSInstance instance) {
    Environment environment = Environment(_closure);
    environment.define("this", instance);
    return UserRoutine(_declaration, environment, _isInitializer);
  }
}
