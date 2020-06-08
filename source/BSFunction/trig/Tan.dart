import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../inverseTrig/ArcTan.dart';
import '../singleOperandFunction.dart';
import 'Sec.dart';

bscFunction tan(bscFunction operand, [bool negative = false]) {
  if (operand is ArcTan)
    return operand.operand.invertSign(negative);
  else
    return Tan._(operand, negative);
}

class Tan extends singleOperandFunction {
  Tan._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  bscFunction derivative(Variable v) =>
      ((sec(operand) ^ n(2)) * operand.derivative(v)).withSign(negative);

  @override
  num call(Map<String, double> p) => math.tan(operand(p)) * factor;

  @override
  bscFunction withSign(bool negative) => Tan._(operand, negative);
}
