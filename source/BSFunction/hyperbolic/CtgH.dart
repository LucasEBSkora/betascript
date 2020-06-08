import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCtgH.dart';
import '../singleOperandFunction.dart';
import 'CscH.dart';

bscFunction ctgh(bscFunction operand, [bool negative = false]) {
  if (operand is ArCtgH)
    return operand.operand.invertSign(negative);
  else
    return CtgH._(operand, negative);
}

class CtgH extends singleOperandFunction {
  CtgH._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  bscFunction derivative(Variable v) =>
      ((-csch(operand) ^ n(2)) * operand.derivative(v)).invertSign(negative);

  @override
  num call(Map<String, double> p) => _coth(operand(p)) * factor;

  @override
  bscFunction withSign(bool negative) => CtgH._(operand, negative);
}

double _coth(double v) =>
    (math.exp(v) + math.exp(-v)) / (math.exp(v) - math.exp(-v));
