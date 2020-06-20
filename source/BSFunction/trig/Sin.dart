import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import '../inverseTrig/ArcSin.dart';
import '../singleOperandFunction.dart';
import 'Cos.dart';
import 'dart:math' as math;

BSFunction sin(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is ArcSin)
    return operand.operand.invertSign(negative);
  else
    return Sin._(operand, negative, params);
}

class Sin extends singleOperandFunction {
  Sin._(BSFunction operand, bool negative, Set<Variable> params) : super(operand, negative, params);

  @override
  BSFunction derivative(Variable v) =>
      (cos(operand) * (operand.derivative(v))).invertSign(negative);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = math.sin(op.value) * factor;
      //Doesn't cover nearly enough angles with exact sines, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return sin(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(math.sin(op.value) * factor);
    return sin(op, negative);
  }

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => Sin._(operand, negative, params);
}
