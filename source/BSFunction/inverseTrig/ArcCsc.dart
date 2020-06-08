import '../Abs.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';
import '../trig/Csc.dart';

bscFunction arccsc(bscFunction operand, [bool negative = false]) {
  if (operand is Csc)
    return operand.operand.invertSign(negative);
  else
    return ArcCsc._(operand, negative);
}

class ArcCsc extends singleOperandFunction {
  ArcCsc._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  num call(Map<String, double> p) => math.asin(1 / operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (operand.derivative(v) / (abs(operand) * root((operand ^ n(2)) - n(1))))
          .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArcCsc._(operand, negative);
}
