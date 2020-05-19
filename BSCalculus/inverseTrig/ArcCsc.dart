import '../Abs.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../trig/Csc.dart';

bscFunction arccsc(bscFunction operand, [bool negative = false]) {
  if (operand is Csc)
    return operand.operand.invertSign(negative);
  else
    return ArcCsc._(operand, negative);
}

class ArcCsc extends bscFunction {
  final bscFunction operand;

  ArcCsc._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => math.asin(1 / operand(p));

  @override
  bscFunction derivative(Variable v) => (operand.derivative(v) /
          (abs(operand) * root((operand ^ n(2)) - n(1))))
      .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArcCsc._(operand, negative);

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
        'arccsc(' +
        operand.toString() +
        ')';
  }
}
