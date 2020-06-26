import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/TanH.dart';
import '../singleOperandFunction.dart';

BSFunction artanh(BSFunction operand) {
  if (operand is TanH)
    return operand.operand;
  else
    return ArTanH._(operand);
}

class ArTanH extends singleOperandFunction {
  ArTanH._(BSFunction operand, [Set<Variable> params = null]) : super(operand, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return artanh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_artanh(op.value));
    else
      return artanh(op);
  }

  @override
  BSFunction derivativeInternal(Variable v) =>
      (operand.derivativeInternal(v) / (n(1) - (operand ^ n(2))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArTanH._(operand, params);
}

double _artanh(double v) => (1 / 2) * math.log((1 + v) / (1 - v));
