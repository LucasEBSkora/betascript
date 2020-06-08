import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArSecH.dart';
import '../singleOperandFunction.dart';
import 'TanH.dart';

bscFunction sech(bscFunction operand, [bool negative = false]) {
  if (operand is ArSecH)
    return operand.operand.invertSign(negative);
  else
    return SecH._(operand, negative);
}

class SecH extends singleOperandFunction {
  SecH._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  bscFunction derivative(Variable v) =>
      (-sech(operand) * tanh(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  num call(Map<String, double> p) => _sech(operand(p)) * factor;

  @override
  bscFunction withSign(bool negative) => SecH._(operand, negative);
}

double _sech(double v) => 2 / (math.exp(v) + math.exp(-v));
