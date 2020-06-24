import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArTanH.dart';
import '../singleOperandFunction.dart';

BSFunction tanh(BSFunction operand, [Set<Variable> params = null]) {
  if (operand is ArTanH)
    return operand.operand;
  else
    return TanH._(operand, params);
}

class TanH extends singleOperandFunction {
  TanH._(BSFunction operand, Set<Variable> params) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      ((sech(operand) ^ n(2)) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return tanh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_tanh(op.value));
    else
      return tanh(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => TanH._(operand, params);
}

double _tanh(double v) =>
    (math.exp(v) - math.exp(-v)) / (math.exp(v) + math.exp(-v));
