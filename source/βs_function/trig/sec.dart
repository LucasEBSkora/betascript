import 'dart:collection' show HashMap;
import 'dart:math' as math;

import 'tan.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../inverse_trig/arcsec.dart';

BSFunction sec(BSFunction operand) {
  return (operand is ArcSec) ? operand.operand : Sec._(operand);
}

class Sec extends singleOperandFunction {
  Sec._(BSFunction operand, [Set<Variable> params]) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (sec(operand) * tan(operand) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = 1 / math.cos(op.value);
      //Doesn't cover nearly enough angles with exact secants, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return sec(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(1 / math.cos(op.value));
    return sec(op);
  }

  @override
  BSFunction copy([Set<Variable> params]) => Sec._(operand, params);
}
