import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

class ArcCtg extends bscFunction {
  final bscFunction operand;

  ArcCtg(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => math.atan(1 / operand(p));

  @override
  bscFunction derivative(Variable p) => -operand.derivative(p)/(Number(1) + operand^Number(2));

  @override
  bscFunction withSign(bool negative) => ArcCtg(operand, negative);

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
        'arctg(' +
        operand.toString() +
        ')';
  }
}
