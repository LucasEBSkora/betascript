import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

bscFunction arctan(bscFunction operand, [bool negative = false]) {
  if (operand is Tan)
    return operand.operand.invertSign(negative);
  else
    return ArcTan._(operand, negative);
}


class ArcTan extends bscFunction {
  final bscFunction operand;

  ArcTan._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => math.atan(operand(p))*factor;

  @override
  bscFunction derivative(Variable v) => (operand.derivative(v)/(n(1) + (operand^n(2)))).invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArcTan._(operand, negative);

  @override
  String toString([bool handleMinus = true]) => "${minusSign(handleMinus)}arctan($operand)";
}
