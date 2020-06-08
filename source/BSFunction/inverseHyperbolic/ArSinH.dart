import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/SinH.dart';
import '../singleOperandFunction.dart';

bscFunction arsinh(bscFunction operand, [bool negative = false]) {
  if (operand is SinH)
    return operand.operand.invertSign(negative);
  else
    return ArSinH._(operand, negative);
}

class ArSinH extends singleOperandFunction {
  ArSinH._(bscFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  num call(Map<String, double> p) => _arsinh(operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (operand.derivative(v) / root(n(1) + (operand ^ n(2))))
          .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArSinH._(operand, negative);
}

double _arsinh(double v) => math.log(v + math.sqrt(1 + math.pow(v, 2)));
