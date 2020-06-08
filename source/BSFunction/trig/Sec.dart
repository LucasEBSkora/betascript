import '../Variable.dart';
import '../bscFunction.dart';
import '../inverseTrig/ArcSec.dart';
import '../singleOperandFunction.dart';
import 'Tan.dart';
import 'dart:math' as math;

bscFunction sec(bscFunction operand, [bool negative = false]) {
  if (operand is ArcSec)
    return operand.operand.invertSign(negative);
  else
    return Sec._(operand, negative);
}

class Sec extends singleOperandFunction {
  Sec._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  bscFunction derivative(Variable v) =>
      (sec(operand) * tan(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  num call(Map<String, double> p) => 1 / math.cos(operand(p)) * factor;

  @override
  bscFunction withSign(bool negative) => Sec._(operand, negative);
}
