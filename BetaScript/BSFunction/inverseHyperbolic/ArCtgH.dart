import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CtgH.dart';

bscFunction arctgh(bscFunction operand, [bool negative = false]) {
  if (operand is CtgH)
    return operand.operand.invertSign(negative);
  else
    return ArCtgH._(operand, negative);
}

class ArCtgH extends bscFunction {
  final bscFunction operand;

  ArCtgH._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => _arctgh(operand(p))*factor;

  @override
  bscFunction derivative(Variable v) => (operand.derivative(v)/(n(1) - operand^n(2))).invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArCtgH._(operand, negative);

  @override
  String toString([bool handleMinus = true])  => "${minusSign(handleMinus)}arctgh($operand)";
}

double _arctgh(double v) => 0.5*math.log((v + 1)/(v - 1));