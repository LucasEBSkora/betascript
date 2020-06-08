import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/SecH.dart';
import '../singleOperandFunction.dart';

bscFunction arsech(bscFunction operand, [bool negative = false]) {
  if (operand is SecH)
    return operand.operand.invertSign(negative);
  else
    return ArSecH._(operand, negative);
}

class ArSecH extends singleOperandFunction {
  ArSecH._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  num call(Map<String, double> p) => _arsech(operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (-operand.derivative(v) / (operand * root(n(1) - (operand ^ n(2)))))
          .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArSecH._(operand, negative);
}

double _arsech(double v) => math.log((1 + math.sqrt(1 - math.pow(v, 2))) / v);
