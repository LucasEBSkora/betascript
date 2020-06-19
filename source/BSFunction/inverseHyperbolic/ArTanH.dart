import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/TanH.dart';
import '../singleOperandFunction.dart';

BSFunction artanh(BSFunction operand, [bool negative = false]) {
  if (operand is TanH)
    return operand.operand.invertSign(negative);
  else
    return ArTanH._(operand, negative);
}

class ArTanH extends singleOperandFunction {
  ArTanH._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return artanh(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_artanh(op.value) * factor);
    else
      return artanh(op, negative);
  }
  @override
  BSFunction derivative(Variable v) =>
      (operand.derivative(v) / (n(1) - (operand ^ n(2)))).invertSign(negative);

  @override
  BSFunction withSign(bool negative) => ArTanH._(operand, negative);
}

double _artanh(double v) => (1 / 2) * math.log((1 + v) / (1 - v));
