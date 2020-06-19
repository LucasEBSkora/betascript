import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/SecH.dart';
import '../singleOperandFunction.dart';

BSFunction arsech(BSFunction operand, [bool negative = false]) {
  if (operand is SecH)
    return operand.operand.invertSign(negative);
  else
    return ArSecH._(operand, negative);
}

class ArSecH extends singleOperandFunction {
  ArSecH._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return arsech(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_arsech(op.value) * factor);
    else
      return arsech(op, negative);
  }
  @override
  BSFunction derivative(Variable v) =>
      (-operand.derivative(v) / (operand * root(n(1) - (operand ^ n(2)))))
          .invertSign(negative);

  @override
  BSFunction withSign(bool negative) => ArSecH._(operand, negative);
}

double _arsech(double v) => math.log((1 + math.sqrt(1 - math.pow(v, 2))) / v);
