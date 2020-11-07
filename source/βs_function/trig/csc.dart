import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../number.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../inverse_trig/arccsc.dart';
import '../single_operand_function.dart';
import 'ctg.dart';

BSFunction csc(BSFunction operand) {
  return (operand is ArcCsc) ? operand.operand : Csc._(operand);
}

class Csc extends singleOperandFunction {
  Csc._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (-csc(operand) * ctg(operand) * operand.derivativeInternal(v));
  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
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
