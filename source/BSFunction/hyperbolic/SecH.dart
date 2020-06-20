import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArSecH.dart';
import '../singleOperandFunction.dart';
import 'TanH.dart';

BSFunction sech(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is ArSecH)
    return operand.operand.invertSign(negative);
  else
    return SecH._(operand, negative, params);
}

class SecH extends singleOperandFunction {
  SecH._(BSFunction operand, bool negative, Set<Variable> params)
      : super(operand, negative, params);

  @override
  BSFunction derivative(Variable v) =>
      (-sech(operand) * tanh(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return sech(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_sech(op.value) * factor);
    else
      return sech(op, negative);
  }

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => SecH._(operand, negative, params);
}

double _sech(double v) => 2 / (math.exp(v) + math.exp(-v));
