import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArSecH.dart';
import '../singleOperandFunction.dart';
import 'TanH.dart';

BSFunction sech(BSFunction operand, [bool negative = false]) {
  if (operand is ArSecH)
    return operand.operand.invertSign(negative);
  else
    return SecH._(operand, negative);
}

class SecH extends singleOperandFunction {
  SecH._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction derivative(Variable v) =>
      (-sech(operand) * tanh(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return sech(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_sech(op.value) * factor);
    else
      return sech(op, negative);
  }

  @override
  BSFunction withSign(bool negative) => SecH._(operand, negative);
}

double _sech(double v) => 2 / (math.exp(v) + math.exp(-v));
