import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCosH.dart';
import 'SinH.dart';

bscFunction cosh(bscFunction operand, [bool negative = false]) {
  if (operand is ArCosH)
    return operand.operand.invertSign(negative);
  else
    return CosH._(operand, negative);
}

class CosH extends bscFunction {
  final bscFunction operand;

  CosH._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) =>
      (sinh(operand) * (operand.derivative(v))).invertSign(negative);

  @override
  num call(Map<String, double> p) => _cosh(operand(p))*factor;

  @override
  String toString([bool handleMinus = true]) => " ${minusSign(handleMinus)}cosh($operand)";

  @override
  bscFunction withSign(bool negative) => CosH._(operand, negative);
}

double _cosh(double v) => (math.exp(v) + math.exp(-v))/2;