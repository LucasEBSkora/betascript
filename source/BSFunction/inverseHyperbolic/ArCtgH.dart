import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CtgH.dart';
import '../singleOperandFunction.dart';

BSFunction arctgh(BSFunction operand, [bool negative = false]) {
  if (operand is CtgH)
    return operand.operand.invertSign(negative);
  else
    return ArCtgH._(operand, negative);
}

class ArCtgH extends singleOperandFunction {
  ArCtgH._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return arctgh(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_arctgh(op.value) * factor);
    else
      return arctgh(op, negative);
  }
  @override
  BSFunction derivative(Variable v) =>
      (operand.derivative(v) / (n(1) - operand ^ n(2))).invertSign(negative);

  @override
  BSFunction withSign(bool negative) => ArCtgH._(operand, negative);
}

double _arctgh(double v) => 0.5 * math.log((v + 1) / (v - 1));
