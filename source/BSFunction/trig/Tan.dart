import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';

import '../inverseTrig/ArcTan.dart';
import '../singleOperandFunction.dart';
import 'Sec.dart';

BSFunction tan(BSFunction operand) {
  if (operand is ArcTan)
    return operand.operand;
  else
    return Tan._(operand);
}

class Tan extends singleOperandFunction {
  Tan._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      ((sec(operand) ^ n(2)) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      double v = math.tan(op.value);
      //Doesn't cover nearly enough angles with exact tangents, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return tan(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(math.tan(op.value));
    return tan(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => Tan._(operand, params);
}
