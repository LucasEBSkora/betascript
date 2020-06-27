import 'BSInterpreter.dart';
import 'NativeCallable.dart';

final Map<String, Object> nativeGlobals = {
  "clock": NativeCallable(
      0,
      (BSInterpreter interpreter, List<Object> arguments) =>
          DateTime.now().millisecondsSinceEpoch),
};