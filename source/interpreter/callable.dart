import 'interpreter.dart';

///Anything that can be called, meaning routines, functions and classes
abstract class BSCallable {
  ///Number of parameters arguments needs to have
  int get arity;

  const BSCallable();

  Object callThing(BSInterpreter interpreter, List<Object> arguments);
}
