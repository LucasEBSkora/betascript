import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCosH.dart';
import '../singleOperandFunction.dart';
import 'SinH.dart';

BSFunction cosh(BSFunction operand, [Set<Variable> params = null]) {
  if (operand is ArCosH)
    return operand.operand;
  else
    return CosH._(operand, params);
}

class CosH extends singleOperandFunction {
  CosH._(BSFunction operand, Set<Variable> params) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      sinh(operand) * (operand.derivativeInternal(v));

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return cosh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_cosh(op.value));
    else
      return cosh(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => CosH._(operand, params);
}

double _cosh(double v) => (math.exp(v) + math.exp(-v)) / 2;
