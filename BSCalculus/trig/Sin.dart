import '../Variable.dart';
import '../bscFunction.dart';
import '../inverseTrig/inverseTrig.dart';
import 'Cos.dart';
import 'dart:math' as math;

bscFunction sin(bscFunction operand, [bool negative = false]) {
  if (operand is ArcSin)
    return operand.operand.invertSign(negative);
  else
    return Sin._(operand, negative);
}

class Sin extends bscFunction {

  final bscFunction operand;

  Sin._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => (cos(operand)*(operand.derivative(v))).invertSign(negative);

  @override
  num call(Map<String, double> p) => math.sin(operand(p));

  @override
  String toString([bool handleMinus = true]) => (negative ? '-' : '') + 'sin(' + operand.toString() + ')';

  @override
  bscFunction withSign(bool negative) => Sin._(operand, negative);

}