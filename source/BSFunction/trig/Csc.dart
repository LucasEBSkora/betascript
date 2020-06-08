import '../Variable.dart';
import '../bscFunction.dart';
import '../inverseTrig/ArcCsc.dart';
import '../singleOperandFunction.dart';
import 'Ctg.dart';
import 'dart:math' as math;

bscFunction csc(bscFunction operand, [bool negative = false]) {
  if (operand is ArcCsc)
    return operand.operand.invertSign(negative);
  else
    return Csc._(operand, negative);
}

class Csc extends singleOperandFunction {

  Csc._(bscFunction operand, [bool negative = false]) : super(operand, negative);

  @override
  bscFunction derivative(Variable v) =>
      (-csc(operand) * ctg(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  num call(Map<String, double> p) => 1 / math.sin(operand(p)) * factor;

  @override
  bscFunction withSign(bool negative) => Csc._(operand, negative);

}
