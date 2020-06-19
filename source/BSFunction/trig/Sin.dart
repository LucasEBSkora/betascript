import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import '../inverseTrig/ArcSin.dart';
import '../singleOperandFunction.dart';
import 'Cos.dart';
import 'dart:math' as math;

BSFunction sin(BSFunction operand, [bool negative = false]) {
  if (operand is ArcSin)
    return operand.operand.invertSign(negative);
  else
    return Sin._(operand, negative);
}

class Sin extends singleOperandFunction {
  Sin._(BSFunction operand, [bool negative = false]) : super(operand, negative);

  @override
  BSFunction derivative(Variable v) =>
      (cos(operand) * (operand.derivative(v))).invertSign(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      double v = math.sin(op.value) * factor;
      //Doesn't cover nearly enough angles with exact sines, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return sin(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(math.sin(op.value) * factor);
    return sin(op, negative);
  }

  @override
  BSFunction withSign(bool negative) => Sin._(operand, negative);
}
