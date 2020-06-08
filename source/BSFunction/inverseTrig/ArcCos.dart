import '../BSCalculus.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';

bscFunction arccos(bscFunction operand, [bool negative = false]) {
  if (operand is Cos)
    return operand.operand.invertSign(negative);
  else
    return ArcCos._(operand, negative);
}

class ArcCos extends singleOperandFunction {
  ArcCos._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  num call(Map<String, double> p) => math.acos(operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (-operand.derivative(v) / root(n(1) - (operand ^ n(2))))
          .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArcCos._(operand, negative);
}
