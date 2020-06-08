import 'BSCallable.dart';
import 'BSEnvironment.dart';
import 'BSInstance.dart';
import 'BSInterpreter.dart';
import 'Stmt.dart';

class UserFunction implements BSCallable {
  final FunctionStmt _declaration;
  final Environment _closure;
  final bool _isInitializer;

  UserFunction(this._declaration, this._closure, this._isInitializer);

  @override
  int get arity => _declaration.parameters.length;

  @override
  Object call(BSInterpreter interpreter, List<Object> arguments) {
    //Creates function scope
    Environment environment = new Environment(_closure);
    
    //defines and initializes parameters in function scope

    //Assumes it is safe to iterate in both lists because arity was checked in Interpreter.VisitCallExpr
    for (int i = 0; i < _declaration.parameters.length; ++i) 
      environment.define(_declaration.parameters[i].lexeme, arguments[i]);
    
    //executes block
    //using exceptions as a way to exit the function and return here, with the proper return value
    try {
      interpreter.executeBlock(_declaration.body, environment);
    } on Return catch (r) {
      if (_isInitializer) return _closure.getAt(0, "this");
      return r.value;
    }

    //if the function is a constructor, returns this regardless of return statements inside it
    return (_isInitializer) ? _closure.getAt(0, "this") : null; 
  }

  @override
  String toString() => "<fn ${_declaration.name.lexeme}>";

  ///Creates a new scope for the method copying the old one and includes the "variable" 'this' in it
  UserFunction bind(BSInstance instance) {
    Environment environment = new Environment(_closure);
    environment.define("this", instance);
    return new UserFunction(_declaration, environment, _isInitializer);

  }
}