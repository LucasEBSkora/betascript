import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';

BSFunction arcsin(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is Sin)
    return operand.operand.invertSign(negative);
  else
    return ArcSin._(operand, negative, params);
}

class ArcSin extends singleOperandFunction {
  ArcSin._(BSFunction operand, bool negative, Set<Variable> params)
      : super(operand, negative, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcsin(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.asin(op.value) * factor);
    else
      return arcsin(op, negative);
  }
  @override
  BSFunction derivative(Variable v) =>
      (operand.derivative(v) / root(n(1) - (operand ^ n(2))))
          .invertSign(negative);

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => ArcSin._(operand, negative, params);
}
