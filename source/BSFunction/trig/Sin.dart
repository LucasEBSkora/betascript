import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import '../inverseTrig/ArcSin.dart';
import '../singleOperandFunction.dart';
import 'Cos.dart';
import 'dart:math' as math;

BSFunction sin(BSFunction operand, [Set<Variable> params = null]) {
  if (operand is ArcSin)
    return operand.operand;
  else
    return Sin._(operand, params);
}

class Sin extends singleOperandFunction {
  Sin._(BSFunction operand,  Set<Variable> params) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (cos(operand) * (operand.derivativeInternal(v)));

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = math.sin(op.value);
      //Doesn't cover nearly enough angles with exact sines, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return sin(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(math.sin(op.value));
    return sin(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => Sin._(operand, params);
}
