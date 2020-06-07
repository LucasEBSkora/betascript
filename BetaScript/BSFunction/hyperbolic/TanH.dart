import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArTanH.dart';



bscFunction tanh(bscFunction operand, [bool negative = false]) {
  if (operand is ArTanH)
    return operand.operand.invertSign(negative);
  else
    return TanH._(operand, negative);
}

class TanH extends bscFunction {

  final bscFunction operand;

  TanH._(bscFunction this.operand, [bool negative = false]) : super(negative);
  
  @override
  bscFunction derivative(Variable v) => ((sech(operand)^n(2))*operand.derivative(v)).withSign(negative);

  @override
  num call(Map<String, double> p) => _tanh(operand(p))*factor;


  @override
  String toString([bool handleMinus = true]) => "${minusSign(handleMinus)}tanh($operand)";

  @override
  bscFunction withSign(bool negative) => TanH._(operand, negative);

}

double _tanh(double v) => (math.exp(v)-math.exp(-v))/(math.exp(v)+math.exp(-v));