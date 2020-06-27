

import 'BSInterpreter.dart';

///Anything that can be called, meaning routines, functions and classes
abstract class BSCallable {
  ///Number of parameters arguments needs to have
  int get arity;
  
  Object call(BSInterpreter interpreter, List<Object> arguments);
}

