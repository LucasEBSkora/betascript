import '../Variable.dart';
import '../bscFunction.dart';
import '../inverseTrig/ArcSec.dart';
import 'Tan.dart';
import 'dart:math' as math;

bscFunction sec(bscFunction operand, [bool negative = false]) {
  if (operand is ArcSec)
    return operand.operand.invertSign(negative);
  else
    return Sec._(operand, negative);
}

class Sec extends bscFunction {

  final bscFunction operand;

  Sec._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => (sec(operand)*tan(operand)*operand.derivative(v)).invertSign(negative);

  @override
  num call(Map<String, double> p) => 1/math.cos(operand(p))*factor;

  @override
  String toString([bool handleMinus = true]) => "${minusSign(handleMinus)}sec($operand)";

  @override
  bscFunction withSign(bool negative) => Sec._(operand, negative);

}