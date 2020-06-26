import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArSecH.dart';
import '../singleOperandFunction.dart';
import 'TanH.dart';

BSFunction sech(BSFunction operand) {
  if (operand is ArSecH)
    return operand.operand;
  else
    return SecH._(operand);
}

class SecH extends singleOperandFunction {
  SecH._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (-sech(operand) * tanh(operand) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return sech(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_sech(op.value));
    else
      return sech(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => SecH._(operand, params);
}

double _sech(double v) => 2 / (math.exp(v) + math.exp(-v));
