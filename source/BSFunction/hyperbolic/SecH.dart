import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArSecH.dart';
import 'TanH.dart';

bscFunction sech(bscFunction operand, [bool negative = false]) {
  if (operand is ArSecH)
    return operand.operand.invertSign(negative);
  else
    return SecH._(operand, negative);
}

class SecH extends bscFunction {
  final bscFunction operand;

  SecH._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) =>
      (-sech(operand) * tanh(operand) * operand.derivative(v))
          .invertSign(negative);

  @override
  num call(Map<String, double> p) => _sech(operand(p)) * factor;

  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}sech($operand)";

  @override
  bscFunction withSign(bool negative) => SecH._(operand, negative);

  @override
  Set<Variable> get parameters => operand.parameters;
}

double _sech(double v) => 2 / (math.exp(v) + math.exp(-v));
