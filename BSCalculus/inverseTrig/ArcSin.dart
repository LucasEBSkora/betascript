import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

bscFunction arcsin(bscFunction operand, [bool negative = false]) {
  if (operand is Sin)
    return operand.operand.invertSign(negative);
  else
    return ArcSin._(operand, negative);
}


class ArcSin extends bscFunction {
  final bscFunction operand;

  ArcSin._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => math.asin(operand(p))*factor;

  @override
  bscFunction derivative(Variable v) => (operand.derivative(v)/root(n(1) - (operand^n(2)))).invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArcSin._(operand, negative);

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
        'arcsin(' +
        operand.toString() +
        ')';
  }
}
