import 'callable.dart';
import '../function/function.dart';
import 'interpreter.dart';

class FunctionAdapter implements BSCallable {
  final BSFunction adaptee;

  const FunctionAdapter(this.adaptee);

  @override
  int get arity => adaptee.parameters.length;

  //Doesn't check if the cast is succesful because it assumes the interpreter did its job
  @override
  Object callThing(BSInterpreter interpreter, List<Object> arguments) =>
      adaptee(arguments.map((object) => object as BSFunction).toList());

  @override
  String toString() => adaptee.toString();
}
