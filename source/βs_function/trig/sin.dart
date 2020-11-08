import 'dart:collection' show HashMap;
import 'dart:math' as math;

import 'cos.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../inverse_trig/arcsin.dart';

BSFunction sin(BSFunction operand) {
  return (operand is ArcSin) ? operand.operand : Sin._(operand);
}

class Sin extends singleOperandFunction {
  const Sin._(BSFunction operand, [Set<Variable> params])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (cos(operand) * (operand.derivativeInternal(v)));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      double v = math.sin(op.value);
      //Doesn't cover nearly enough angles with exact sines, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return sin(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) return n(math.sin(op.value));
    return sin(op);
  }

  @override
  BSFunction copy([Set<Variable> params]) => Sin._(operand, params);
}
