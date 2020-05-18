import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

class ArcCsc extends bscFunction {
  final bscFunction operand;

  ArcCsc(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => math.asin(1 / operand(p));

  @override
  bscFunction derivative(Variable p) {
    //TODO:: implement derivative of ArcCsc - needs root
    throw UnimplementedError();
  }

  @override
  bscFunction withSign(bool negative) => ArcCsc(operand, negative);

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
        'arccsc(' +
        operand.toString() +
        ')';
  }
}
