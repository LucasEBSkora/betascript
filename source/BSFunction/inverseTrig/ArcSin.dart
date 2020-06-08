import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';

bscFunction arcsin(bscFunction operand, [bool negative = false]) {
  if (operand is Sin)
    return operand.operand.invertSign(negative);
  else
    return ArcSin._(operand, negative);
}

class ArcSin extends singleOperandFunction {
  ArcSin._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  num call(Map<String, double> p) => math.asin(operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (operand.derivative(v) / root(n(1) - (operand ^ n(2))))
          .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArcSin._(operand, negative);
}
