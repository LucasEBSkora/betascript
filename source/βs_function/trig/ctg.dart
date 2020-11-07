import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../number.dart';
import '../variable.dart';
import '../βs_function.dart';

import '../inverse_trig/arcctg.dart';
import '../single_operand_function.dart';
import 'csc.dart';

BSFunction ctg(BSFunction operand) {
  if (operand is ArcCtg)
    return operand.operand;
  else
    return Ctg._(operand);
}

class Ctg extends singleOperandFunction {
  Ctg._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      ((-csc(operand) ^ n(2)) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
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
