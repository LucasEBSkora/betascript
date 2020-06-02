

import 'BSEnvironment.dart';
import 'BSInterpreter.dart';
import 'Stmt.dart';

///Anything that can be called, meaning functions and classes
abstract class BSCallable {
  ///Number of parameters arguments needs to have
  int get arity;
  
  Object call(BSInterpreter interpreter, List<Object> arguments);
}

///An implementation of BSCallable used to create native functions
class NativeCallable implements BSCallable {
  final int _arity;
  final Function _function;

  NativeCallable(this._arity, this._function);

  @override
  int get arity => _arity;

  @override
  Object call(BSInterpreter interpreter, List<Object> arguments) => _function(interpreter, arguments);
  
  @override
  String toString() => "Native function";
}

class UserFunction implements BSCallable {
  final FunctionStmt _declaration;

  UserFunction(this._declaration);

  @override
  int get arity => _declaration.parameters.length;

  @override
  Object call(BSInterpreter interpreter, List<Object> arguments) {
    //Creates function scope
    Environment environment = new Environment(interpreter.globals);
    
    //defines and initializes parameters in function scope

    //Assumes it is safe to iterate in both lists because arity was checked in Interpreter.VisitCallExpr
    for (int i = 0; i < _declaration.parameters.length; ++i) 
      environment.define(_declaration.parameters[i].lexeme, arguments[i]);
    
    //executes block
    interpreter.executeBlock(_declaration.body, environment);
    return null;
  }

  @override
  String toString() => "<fn ${_declaration.name.lexeme}>";
}