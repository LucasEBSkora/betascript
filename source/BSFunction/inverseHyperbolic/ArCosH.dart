import '../BSCalculus.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CosH.dart';

bscFunction arcosh(bscFunction operand, [bool negative = false]) {
  if (operand is CosH)
    return operand.operand.invertSign(negative);
  else
    return ArCosH._(operand, negative);
}

class ArCosH extends bscFunction {
  final bscFunction operand;

  ArCosH._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => _arcosh(operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (operand.derivative(v) / root((operand ^ n(2)) - n(1)))
          .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArCosH._(operand, negative);

  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}arcosh($operand)";

  @override
  Set<Variable> get parameters => operand.parameters;
}

double _arcosh(double v) => math.log(v + math.sqrt(math.pow(v, 2) - 1));
