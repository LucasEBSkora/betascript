import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';

import '../inverseHyperbolic/ArSinH.dart';
import '../singleOperandFunction.dart';
import 'CosH.dart';

BSFunction sinh(BSFunction operand) {
  if (operand is ArSinH)
    return operand.operand;
  else
    return SinH._(operand);
}

class SinH extends singleOperandFunction {
  SinH._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (cosh(operand) * (operand.derivativeInternal(v)));
  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return sinh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_sinh(op.value));
    else
      return sinh(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => SinH._(operand, params);
}

double _sinh(double v) => (math.exp(v) - math.exp(-v)) / 2;
