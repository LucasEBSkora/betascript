import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_calculus.dart';
import '../βs_function.dart';
import '../hyperbolic/tanh.dart';

BSFunction artanh(BSFunction operand) {
  return (operand is TanH) ? operand.operand : ArTanH._(operand);
}

class ArTanH extends singleOperandFunction {
  ArTanH._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return artanh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) {
      return n(_artanh(op.value));
    } else {
      return artanh(op);
    }
  }

  @override
  BSFunction derivativeInternal(Variable v) =>
      (operand.derivativeInternal(v) / (n(1) - (operand ^ n(2))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArTanH._(operand, params);
}

double _artanh(double v) => (1 / 2) * math.log((1 + v) / (1 - v));
