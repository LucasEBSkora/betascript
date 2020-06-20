import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import '../inverseTrig/ArcSec.dart';
import '../singleOperandFunction.dart';
import 'Tan.dart';
import 'dart:math' as math;

BSFunction sec(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is ArcSec)
    return operand.operand.invertSign(negative);
  else
    return Sec._(operand, negative, params);
}

class Sec extends singleOperandFunction {
  Sec._(BSFunction operand, bool negative, Set<Variable> params) : super(operand, negative, params);

  @override
  BSFunction derivative(Variable v) =>
      (sec(operand) * tan(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
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
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => Sec._(operand, negative, params);
}
