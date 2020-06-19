import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArTanH.dart';
import '../singleOperandFunction.dart';

BSFunction tanh(BSFunction operand, [bool negative = false]) {
  if (operand is ArTanH)
    return operand.operand.invertSign(negative);
  else
    return TanH._(operand, negative);
}

class TanH extends singleOperandFunction {
  TanH._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction derivative(Variable v) =>
      ((sech(operand) ^ n(2)) * operand.derivative(v)).withSign(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return tanh(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_tanh(op.value) * factor);
    else
      return tanh(op, negative);
  }
  @override
  BSFunction withSign(bool negative) => TanH._(operand, negative);
}

double _tanh(double v) =>
    (math.exp(v) - math.exp(-v)) / (math.exp(v) + math.exp(-v));
