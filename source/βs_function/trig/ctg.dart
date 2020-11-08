import 'dart:collection' show HashMap;
import 'dart:math' as math;

import 'csc.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../inverse_trig/arcctg.dart';

BSFunction ctg(BSFunction operand) {
  return (operand is ArcCtg) ? operand.operand : Ctg._(operand);
}

class Ctg extends singleOperandFunction {
  Ctg._(BSFunction operand, [Set<Variable> params]) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      ((-csc(operand) ^ n(2)) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      double v = 1 / math.tan(op.value);
      //Doesn't cover nearly enough angles with exact cotagents, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return ctg(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) return n(1 / math.tan(op.value));
    return ctg(op);
  }

  @override
  BSFunction copy([Set<Variable> params]) => Ctg._(operand, params);
}
