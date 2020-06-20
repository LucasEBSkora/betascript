import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';

BSFunction arcctg(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is Ctg)
    return operand.operand.invertSign(negative);
  else
    return ArcCtg._(operand, negative, params);
}

class ArcCtg extends singleOperandFunction {
  ArcCtg._(BSFunction operand, bool negative, Set<Variable> params)
      : super(operand, negative, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcctg(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.atan(1 / op.value) * factor);
    else
      return arcctg(op, negative);
  }

  @override
  BSFunction derivative(Variable v) =>
      (-operand.derivative(v) / (n(1) + (operand ^ n(2)))).invertSign(negative);

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => ArcCtg._(operand, negative, params);
}
