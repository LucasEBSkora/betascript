import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../number.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../inverse_trig/arcsin.dart';
import '../single_operand_function.dart';
import 'cos.dart';

BSFunction sin(BSFunction operand) {
  return (operand is ArcSin) ? operand.operand : Sin._(operand);
}

class Sin extends singleOperandFunction {
  Sin._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (cos(operand) * (operand.derivativeInternal(v)));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = math.sin(op.value);
      //Doesn't cover nearly enough angles with exact sines, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return sin(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(math.sin(op.value));
    return sin(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => Sin._(operand, params);
}
