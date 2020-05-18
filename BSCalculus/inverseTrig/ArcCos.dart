import '../BSCalculus.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

class ArcCos extends bscFunction {
  final bscFunction operand;

  ArcCos(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => math.acos(operand(p));

  @override
  bscFunction derivative(Variable v) => (-operand.derivative(v)/Root(Number(1) - operand^Number(2))).invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArcCos(operand, negative);

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
        'arccos(' +
        operand.toString() +
        ')';
  }
}
