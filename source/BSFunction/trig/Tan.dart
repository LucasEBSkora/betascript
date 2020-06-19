import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseTrig/ArcTan.dart';
import '../singleOperandFunction.dart';
import 'Sec.dart';

BSFunction tan(BSFunction operand, [bool negative = false]) {
  if (operand is ArcTan)
    return operand.operand.invertSign(negative);
  else
    return Tan._(operand, negative);
}

class Tan extends singleOperandFunction {
  Tan._(BSFunction operand, [bool negative = false]) : super(operand, negative);

  @override
  BSFunction derivative(Variable v) =>
      ((sec(operand) ^ n(2)) * operand.derivative(v)).withSign(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      double v = math.tan(op.value) * factor;
      //Doesn't cover nearly enough angles with exact tangents, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return tan(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(math.tan(op.value) * factor);
    return tan(op, negative);
  }

  @override
  BSFunction withSign(bool negative) => Tan._(operand, negative);
}
