import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/SinH.dart';

bscFunction arsinh(bscFunction operand, [bool negative = false]) {
  if (operand is SinH)
    return operand.operand.invertSign(negative);
  else
    return ArSinH._(operand, negative);
}

class ArSinH extends bscFunction {
  final bscFunction operand;

  ArSinH._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => _arsinh(operand(p));

  @override
  bscFunction derivative(Variable v) =>
      (operand.derivative(v) / root(n(1) + (operand ^ n(2))))
          .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArSinH._(operand, negative);

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
        'arcsin(' +
        operand.toString() +
        ')';
  }
}

double _arsinh(double v) => math.log(v + math.sqrt(1 + math.pow(v, 2)));
