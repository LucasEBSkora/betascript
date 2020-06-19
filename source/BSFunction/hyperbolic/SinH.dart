import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArSinH.dart';
import '../singleOperandFunction.dart';
import 'CosH.dart';

BSFunction sinh(BSFunction operand, [bool negative = false]) {
  if (operand is ArSinH)
    return operand.operand.invertSign(negative);
  else
    return SinH._(operand, negative);
}

class SinH extends singleOperandFunction {
  SinH._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction derivative(Variable v) =>
      (cosh(operand) * (operand.derivative(v))).invertSign(negative);
  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return sinh(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_sinh(op.value) * factor);
    else
      return sinh(op, negative);
  }
  @override
  BSFunction withSign(bool negative) => SinH._(operand, negative);
}

double _sinh(double v) => (math.exp(v) - math.exp(-v)) / 2;
