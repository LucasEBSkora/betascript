import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';

bscFunction arctan(bscFunction operand, [bool negative = false]) {
  if (operand is Tan)
    return operand.operand.invertSign(negative);
  else
    return ArcTan._(operand, negative);
}

class ArcTan extends singleOperandFunction {
  ArcTan._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  num call(Map<String, double> p) => math.atan(operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (operand.derivative(v) / (n(1) + (operand ^ n(2)))).invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArcTan._(operand, negative);
}
