import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArTanH.dart';
import '../singleOperandFunction.dart';

BSFunction tanh(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is ArTanH)
    return operand.operand.invertSign(negative);
  else
    return TanH._(operand, negative, params);
}

class TanH extends singleOperandFunction {
  TanH._(BSFunction operand, bool negative, Set<Variable> params)
      : super(operand, negative, params);

  @override
  BSFunction derivative(Variable v) =>
      ((sech(operand) ^ n(2)) * operand.derivative(v)).copy(negative);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
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
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => TanH._(operand, negative, params);
}

double _tanh(double v) =>
    (math.exp(v) - math.exp(-v)) / (math.exp(v) + math.exp(-v));
