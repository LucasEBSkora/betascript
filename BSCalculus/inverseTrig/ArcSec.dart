import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

class ArcSec extends bscFunction {
  final bscFunction operand;

  ArcSec(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => math.acos(1 / operand(p));

  @override
  bscFunction derivative(Variable p) {
    //TODO:: implement derivative of ArcSec - needs root
    throw UnimplementedError();
  }

  @override
  bscFunction withSign(bool negative) => ArcSec(operand, negative);

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
        'arcsec(' +
        operand.toString() +
        ')';
  }
}
