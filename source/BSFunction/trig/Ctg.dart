import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseTrig/ArcCtg.dart';
import '../singleOperandFunction.dart';
import 'Csc.dart';

BSFunction ctg(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is ArcCtg)
    return operand.operand.invertSign(negative);
  else
    return Ctg._(operand, negative, params);
}

class Ctg extends singleOperandFunction {
  Ctg._(BSFunction operand, bool negative, Set<Variable> params) : super(operand, negative, params);

  @override
  BSFunction derivative(Variable v) =>
      ((-csc(operand) ^ n(2)) * operand.derivative(v)).invertSign(negative);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = factor / math.tan(op.value);
      //Doesn't cover nearly enough angles with exact cotagents, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return ctg(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(factor / math.tan(op.value));
    return ctg(op, negative);
  }

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => Ctg._(operand, negative, params);
}
