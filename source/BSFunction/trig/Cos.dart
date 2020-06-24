import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import '../inverseTrig/ArcCos.dart';
import '../singleOperandFunction.dart';
import 'Sin.dart';
import 'dart:math' as math;

BSFunction cos(BSFunction operand, [Set<Variable> params = null]) {
  if (operand is ArcCos)
    return operand.operand;
  else
    return Cos._(operand, params);
}

class Cos extends singleOperandFunction {
  
  Cos._(BSFunction operand,  Set<Variable> params) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (-sin(operand) * (operand.derivativeInternal(v)));

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = math.cos(op.value);
      //Doesn't cover nearly enough angles with exact cosines, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return cos(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(math.cos(op.value));
    return cos(op);
  }


  @override
  BSFunction copy([Set<Variable> params = null]) => Cos._(operand, params);

}
