import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCosH.dart';
import '../singleOperandFunction.dart';
import 'SinH.dart';

BSFunction cosh(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is ArCosH)
    return operand.operand.invertSign(negative);
  else
    return CosH._(operand, negative, params);
}

class CosH extends singleOperandFunction {
  CosH._(BSFunction operand, bool negative, Set<Variable> params)
      : super(operand, negative, params);

  @override
  BSFunction derivative(Variable v) =>
      (sinh(operand) * (operand.derivative(v))).invertSign(negative);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return cosh(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_cosh(op.value) * factor);
    else
      return cosh(op, negative);
  }

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => CosH._(operand, negative, params);
}

double _cosh(double v) => (math.exp(v) + math.exp(-v)) / 2;
