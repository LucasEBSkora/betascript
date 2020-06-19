import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCtgH.dart';
import '../singleOperandFunction.dart';
import 'CscH.dart';

BSFunction ctgh(BSFunction operand, [bool negative = false]) {
  if (operand is ArCtgH)
    return operand.operand.invertSign(negative);
  else
    return CtgH._(operand, negative);
}

class CtgH extends singleOperandFunction {
  CtgH._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction derivative(Variable v) =>
      ((-csch(operand) ^ n(2)) * operand.derivative(v)).invertSign(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return ctgh(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_ctgh(op.value) * factor);
    else
      return ctgh(op, negative);
  }

  @override
  BSFunction withSign(bool negative) => CtgH._(operand, negative);
}

double _ctgh(double v) =>
    (math.exp(v) + math.exp(-v)) / (math.exp(v) - math.exp(-v));
