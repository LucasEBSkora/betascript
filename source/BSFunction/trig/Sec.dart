import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import '../inverseTrig/ArcSec.dart';
import '../singleOperandFunction.dart';
import 'Tan.dart';
import 'dart:math' as math;

BSFunction sec(BSFunction operand, [bool negative = false]) {
  if (operand is ArcSec)
    return operand.operand.invertSign(negative);
  else
    return Sec._(operand, negative);
}

class Sec extends singleOperandFunction {
  Sec._(BSFunction operand, [bool negative = false]) : super(operand, negative);

  @override
  BSFunction derivative(Variable v) =>
      (sec(operand) * tan(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      double v = factor / math.cos(op.value);
      //Doesn't cover nearly enough angles with exact secants, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return sec(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(factor / math.cos(op.value));
    return sec(op, negative);
  }

  @override
  BSFunction withSign(bool negative) => Sec._(operand, negative);
}
