import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCscH.dart';
import '../singleOperandFunction.dart';
import 'CtgH.dart';

BSFunction csch(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is ArCscH)
    return operand.operand.invertSign(negative);
  else
    return CscH._(operand, negative, params);
}

class CscH extends singleOperandFunction {
  CscH._(BSFunction operand, bool negative, Set<Variable> params)
      : super(operand, negative, params);

  @override
  BSFunction derivative(Variable v) =>
      (-csch(operand) * ctgh(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return csch(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_csch(op.value) * factor);
    else
      return csch(op, negative);
  }
  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => CscH._(operand, negative, params);
}

double _csch(double v) => 2 / (math.exp(v) - math.exp(-v));
