import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArSinH.dart';
import '../singleOperandFunction.dart';
import 'CosH.dart';

bscFunction sinh(bscFunction operand, [bool negative = false]) {
  if (operand is ArSinH)
    return operand.operand.invertSign(negative);
  else
    return SinH._(operand, negative);
}

class SinH extends singleOperandFunction {
  SinH._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  bscFunction derivative(Variable v) =>
      (cosh(operand) * (operand.derivative(v))).invertSign(negative);

  @override
  num call(Map<String, double> p) => _sinh(operand(p)) * factor;

  @override
  bscFunction withSign(bool negative) => SinH._(operand, negative);
}

double _sinh(double v) => (math.exp(v) - math.exp(-v)) / 2;
