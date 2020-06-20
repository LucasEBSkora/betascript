import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseTrig/ArcTan.dart';
import '../singleOperandFunction.dart';
import 'Sec.dart';

BSFunction tan(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is ArcTan)
    return operand.operand.invertSign(negative);
  else
    return Tan._(operand, negative, params);
}

class Tan extends singleOperandFunction {
  Tan._(BSFunction operand, bool negative, Set<Variable> params) : super(operand, negative, params);

  @override
  BSFunction derivative(Variable v) =>
      ((sec(operand) ^ n(2)) * operand.derivative(v)).copy(negative);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
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
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => Tan._(operand, negative, params);
}
