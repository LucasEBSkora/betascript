import 'native_callable.dart';
import 'interpreter.dart';
import '../sets/sets.dart';
import '../function/functions.dart';

final _x = variable("x");
final _b = variable("b");

final Map<String, Object> nativeGlobals = {
  //actual native routines
  "clock": NativeCallable(
      0,
      (BSInterpreter interpreter, List<Object> arguments) =>
          DateTime.now().millisecondsSinceEpoch),
  //exposing functions
  "abs": abs(_x),
  "sgn": sgn(_x),
  "sqrt": root(_x),
  "log": log(_x, _b).withParameters(<Variable>{_x, _b}),
  "ln": log(_x),

  //trig
  "sin": sin(_x),
  "cos": cos(_x),
  "tan": tan(_x),
  "sec": sec(_x),
  "csc": csc(_x),
  "ctg": ctg(_x),

  //inverse trig
  "arcsin": arcsin(_x),
  "arccos": arccos(_x),
  "arctan": arctan(_x),
  "arcsec": arcsec(_x),
  "arccsc": arccsc(_x),
  "arcctg": arcctg(_x),

  //hyperbolic
  "sinh": sinh(_x),
  "cosh": cosh(_x),
  "tanh": tanh(_x),
  "sech": sech(_x),
  "csch": csch(_x),
  "ctgh": ctgh(_x),

  //inverse hyperbolic
  "arsinh": arsinh(_x),
  "arcosh": arcosh(_x),
  "artanh": artanh(_x),
  "arsech": arsech(_x),
  "arcsch": arcsch(_x),
  "arctgh": arctgh(_x),

  //constant named numbers
  "e": Constants.e,
  "pi": Constants.pi,
  "π": Constants.pi,
  "infinity": Constants.infinity,
  "∞": Constants.infinity,

  //empty set
  "emptySet": emptySet,
  "∅": emptySet,
};
