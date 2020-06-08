import '../Variable.dart';
import '../bscFunction.dart';
import '../inverseTrig/ArcCos.dart';
import 'Sin.dart';
import 'dart:math' as math;

bscFunction cos(bscFunction operand, [bool negative = false]) {
  if (operand is ArcCos)
    return operand.operand.invertSign(negative);
  else
    return Cos._(operand, negative);
}

class Cos extends bscFunction {
  final bscFunction operand;

  Cos._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) =>
      (-sin(operand) * (operand.derivative(v))).invertSign(negative);

  @override
  num call(Map<String, double> p) => math.cos(operand(p)) * factor;

  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}cos($operand)";

  @override
  bscFunction withSign(bool negative) => Cos._(operand, negative);

  @override
  Set<Variable> get parameters => operand.parameters;
}
