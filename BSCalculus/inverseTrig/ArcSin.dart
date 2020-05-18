import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

class ArcSin extends bscFunction {
  final bscFunction operand;

  ArcSin(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => math.asin(operand(p));

  @override
  bscFunction derivative(Variable v) => (operand.derivative(v)/Root(Number(1) - operand^Number(2))).invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArcSin(operand, negative);

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
        'arcsin(' +
        operand.toString() +
        ')';
  }
}
