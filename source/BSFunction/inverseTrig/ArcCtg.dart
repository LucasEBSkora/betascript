import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';

bscFunction arcctg(bscFunction operand, [bool negative = false]) {
  if (operand is Ctg)
    return operand.operand.invertSign(negative);
  else
    return ArcCtg._(operand, negative);
}

class ArcCtg extends singleOperandFunction {
  ArcCtg._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  num call(Map<String, double> p) => math.atan(1 / operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (-operand.derivative(v) / (n(1) + (operand ^ n(2)))).invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArcCtg._(operand, negative);
}
