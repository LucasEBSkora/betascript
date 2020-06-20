import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import '../inverseTrig/ArcCsc.dart';
import '../singleOperandFunction.dart';
import 'Ctg.dart';
import 'dart:math' as math;

BSFunction csc(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is ArcCsc)
    return operand.operand.invertSign(negative);
  else
    return Csc._(operand, negative, params);
}

class Csc extends singleOperandFunction {

  Csc._(BSFunction operand, bool negative, Set<Variable> params) : super(operand, negative, params);

  @override
  BSFunction derivative(Variable v) =>
      (-csc(operand) * ctg(operand) * operand.derivative(v))
          .invertSign(negative);
  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = factor / math.sin(op.value);
      //Doesn't cover nearly enough angles with exact cossecants, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return csc(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(factor / math.sin(op.value));
    return csc(op, negative);
  }


  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => Csc._(operand, negative, params);

}
