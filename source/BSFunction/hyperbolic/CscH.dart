import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCscH.dart';
import '../singleOperandFunction.dart';
import 'CtgH.dart';

BSFunction csch(BSFunction operand, [bool negative = false]) {
  if (operand is ArCscH)
    return operand.operand.invertSign(negative);
  else
    return CscH._(operand, negative);
}

class CscH extends singleOperandFunction {
  CscH._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction derivative(Variable v) =>
      (-csch(operand) * ctgh(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
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
  BSFunction withSign(bool negative) => CscH._(operand, negative);
}

double _csch(double v) => 2 / (math.exp(v) - math.exp(-v));
