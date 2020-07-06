import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import '../inverseTrig/ArcSec.dart';
import '../singleOperandFunction.dart';
import 'Tan.dart';

BSFunction sec(BSFunction operand) {
  if (operand is ArcSec)
    return operand.operand;
  else
    return Sec._(operand);
}

class Sec extends singleOperandFunction {
  Sec._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

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
  BSFunction copy([Set<Variable> params = null]) => Sec._(operand, params);
}
