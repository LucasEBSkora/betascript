import '../BSCalculus.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CosH.dart';
import '../singleOperandFunction.dart';

bscFunction arcosh(bscFunction operand, [bool negative = false]) {
  if (operand is CosH)
    return operand.operand.invertSign(negative);
  else
    return ArCosH._(operand, negative);
}

class ArCosH extends singleOperandFunction {
  ArCosH._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  num call(Map<String, double> p) => _arcosh(operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (operand.derivative(v) / root((operand ^ n(2)) - n(1)))
          .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArCosH._(operand, negative);
}

double _arcosh(double v) => math.log(v + math.sqrt(math.pow(v, 2) - 1));
