import '../Variable.dart';
import '../bscFunction.dart';
import '../inverseTrig/ArcCos.dart';
import '../singleOperandFunction.dart';
import 'Sin.dart';
import 'dart:math' as math;

bscFunction cos(bscFunction operand, [bool negative = false]) {
  if (operand is ArcCos)
    return operand.operand.invertSign(negative);
  else
    return Cos._(operand, negative);
}

class Cos extends singleOperandFunction {
  
  Cos._(bscFunction operand, [bool negative = false]) : super(operand, negative);

  @override
  bscFunction derivative(Variable v) =>
      (-sin(operand) * (operand.derivative(v))).invertSign(negative);

  @override
  num call(Map<String, double> p) => math.cos(operand(p)) * factor;

  @override
  bscFunction withSign(bool negative) => Cos._(operand, negative);

}
