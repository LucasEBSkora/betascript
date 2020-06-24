import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCtgH.dart';
import '../singleOperandFunction.dart';
import 'CscH.dart';

BSFunction ctgh(BSFunction operand, [Set<Variable> params = null]) {
  if (operand is ArCtgH)
    return operand.operand;
  else
    return CtgH._(operand, params);
}

class CtgH extends singleOperandFunction {
  CtgH._(BSFunction operand, Set<Variable> params)
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      ((-csch(operand) ^ n(2)) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return ctgh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_ctgh(op.value) );
    else
      return ctgh(op);
  }

  @override
  BSFunction copy([ Set<Variable> params = null]) => CtgH._(operand, params);
}

double _ctgh(double v) =>
    (math.exp(v) + math.exp(-v)) / (math.exp(v) - math.exp(-v));
