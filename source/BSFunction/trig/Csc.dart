import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import '../inverseTrig/ArcCsc.dart';
import '../singleOperandFunction.dart';
import 'Ctg.dart';
import 'dart:math' as math;

BSFunction csc(BSFunction operand) {
  if (operand is ArcCsc)
    return operand.operand;
  else
    return Csc._(operand);
}

class Csc extends singleOperandFunction {
  Csc._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (-csc(operand) * ctg(operand) * operand.derivativeInternal(v));
  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = 1 / math.sin(op.value);
      //Doesn't cover nearly enough angles with exact cossecants, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return csc(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(1 / math.sin(op.value));
    return csc(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => Csc._(operand, params);
}
