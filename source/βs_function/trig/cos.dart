import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../number.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../inverse_trig/arccos.dart';
import '../single_operand_function.dart';
import 'sin.dart';

BSFunction cos(BSFunction operand) {
  if (operand is ArcCos)
    return operand.operand;
  else
    return Cos._(operand);
}

class Cos extends singleOperandFunction {
  Cos._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (-sin(operand) * (operand.derivativeInternal(v)));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = math.cos(op.value);
      //Doesn't cover nearly enough angles with exact cosines, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return cos(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(math.cos(op.value));
    return cos(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => Cos._(operand, params);
}
