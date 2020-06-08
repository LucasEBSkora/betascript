import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/TanH.dart';

bscFunction artanh(bscFunction operand, [bool negative = false]) {
  if (operand is TanH)
    return operand.operand.invertSign(negative);
  else
    return ArTanH._(operand, negative);
}

class ArTanH extends bscFunction {
  final bscFunction operand;

  ArTanH._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => _artanh(operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (operand.derivative(v) / (n(1) - (operand ^ n(2)))).invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArTanH._(operand, negative);

  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}artanh($operand)";

  @override
  Set<Variable> get parameters => operand.parameters;
}

double _artanh(double v) => (1 / 2) * math.log((1 + v) / (1 - v));
