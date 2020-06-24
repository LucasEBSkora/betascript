import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseTrig/ArcCtg.dart';
import '../singleOperandFunction.dart';
import 'Csc.dart';

BSFunction ctg(BSFunction operand, [Set<Variable> params = null]) {
  if (operand is ArcCtg)
    return operand.operand;
  else
    return Ctg._(operand, params);
}

class Ctg extends singleOperandFunction {
  Ctg._(BSFunction operand,  Set<Variable> params) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      ((-csc(operand) ^ n(2)) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = 1 / math.tan(op.value);
      //Doesn't cover nearly enough angles with exact cotagents, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return ctg(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(1 / math.tan(op.value));
    return ctg(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => Ctg._(operand, params);
}
