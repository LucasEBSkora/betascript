import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

class ArcSin extends bscFunction {
  final bscFunction operand;

  ArcSin(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => math.asin(operand(p));

  @override
  bscFunction derivative(Variable p) {
    //TODO:: implement derivative of ArcSin - needs root
    throw UnimplementedError();
  }

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
