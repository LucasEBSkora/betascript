import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CscH.dart';

bscFunction arcsch(bscFunction operand, [bool negative = false]) {
  if (operand is CscH)
    return operand.operand.invertSign(negative);
  else
    return ArCscH._(operand, negative);
}

class ArCscH extends bscFunction {
  final bscFunction operand;

  ArCscH._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => _arcsch(operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (-operand.derivative(v) / (operand * root((operand ^ n(2)) + n(1))))
          .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArCscH._(operand, negative);

  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}arcsch($operand)";

  @override
  Set<Variable> get parameters => operand.parameters;
}

double _arcsch(double v) => math.log(math.sqrt(1 + math.pow(v, 2)) / v);
