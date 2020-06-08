import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCtgH.dart';
import 'CscH.dart';

bscFunction ctgh(bscFunction operand, [bool negative = false]) {
  if (operand is ArCtgH)
    return operand.operand.invertSign(negative);
  else
    return CtgH._(operand, negative);
}

class CtgH extends bscFunction {
  final bscFunction operand;

  CtgH._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) =>
      ((-csch(operand) ^ n(2)) * operand.derivative(v)).invertSign(negative);

  @override
  num call(Map<String, double> p) => _coth(operand(p)) * factor;

  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}ctgh($operand)";

  @override
  bscFunction withSign(bool negative) => CtgH._(operand, negative);

  @override
  Set<Variable> get parameters => operand.parameters;
}

double _coth(double v) =>
    (math.exp(v) + math.exp(-v)) / (math.exp(v) - math.exp(-v));
