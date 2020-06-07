import '../Variable.dart';
import '../bscFunction.dart';
import '../inverseTrig/ArcCsc.dart';
import 'Ctg.dart';
import 'dart:math' as math;

bscFunction csc(bscFunction operand, [bool negative = false]) {
  if (operand is ArcCsc)
    return operand.operand.invertSign(negative);
  else
    return Csc._(operand, negative);
}

class Csc extends bscFunction {

  final bscFunction operand;

  Csc._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => (-csc(operand)*ctg(operand)*operand.derivative(v)).invertSign(negative);

  @override
  num call(Map<String, double> p) => 1/math.sin(operand(p))*factor;

  @override
  String toString([bool handleMinus = true]) => "${minusSign(handleMinus)}csc($operand)";

  @override
  bscFunction withSign(bool negative) => Csc._(operand, negative);

}