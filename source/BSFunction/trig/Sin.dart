import '../Variable.dart';
import '../bscFunction.dart';
import '../inverseTrig/ArcSin.dart';
import '../singleOperandFunction.dart';
import 'Cos.dart';
import 'dart:math' as math;

bscFunction sin(bscFunction operand, [bool negative = false]) {
  if (operand is ArcSin)
    return operand.operand.invertSign(negative);
  else
    return Sin._(operand, negative);
}

class Sin extends singleOperandFunction {
  
  Sin._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  bscFunction derivative(Variable v) =>
      (cos(operand) * (operand.derivative(v))).invertSign(negative);

  @override
  num call(Map<String, double> p) => math.sin(operand(p)) * factor;

  @override
  bscFunction withSign(bool negative) => Sin._(operand, negative);
}
