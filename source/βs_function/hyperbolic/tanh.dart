import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../βs_calculus.dart';
import '../number.dart';
import '../variable.dart';
import '../βs_function.dart';

import '../inverse_hyperbolic/artanh.dart';
import '../single_operand_function.dart';
import './sech.dart';

BSFunction tanh(BSFunction operand) {
  if (operand is ArTanH)
    return operand.operand;
  else
    return TanH._(operand);
}

class TanH extends singleOperandFunction {
  TanH._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      ((sech(operand) ^ n(2)) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
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
