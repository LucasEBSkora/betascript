import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCscH.dart';
import '../singleOperandFunction.dart';
import 'CtgH.dart';

bscFunction csch(bscFunction operand, [bool negative = false]) {
  if (operand is ArCscH)
    return operand.operand.invertSign(negative);
  else
    return CscH._(operand, negative);
}

class CscH extends singleOperandFunction {
  CscH._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  bscFunction derivative(Variable v) =>
      (-csch(operand) * ctgh(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  num call(Map<String, double> p) => _csch(operand(p)) * factor;

  @override
  bscFunction withSign(bool negative) => CscH._(operand, negative);
}

double _csch(double v) => 2 / (math.exp(v) - math.exp(-v));
