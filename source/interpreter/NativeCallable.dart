import 'BSCallable.dart';
import 'BSInterpreter.dart';

///An implementation of BSCallable used to create native functions
class NativeCallable implements BSCallable {
  final int _arity;
  final Function _function;

  NativeCallable(this._arity, this._function);

  @override
  int get arity => _arity;

  @override
  Object call(BSInterpreter interpreter, List<Object> arguments) =>
      _function(interpreter, arguments);

  @override
  String toString() => "Native function";
}
