import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CscH.dart';
import '../singleOperandFunction.dart';

bscFunction arcsch(bscFunction operand, [bool negative = false]) {
  if (operand is CscH)
    return operand.operand.invertSign(negative);
  else
    return ArCscH._(operand, negative);
}

class ArCscH extends singleOperandFunction {

  ArCscH._(bscFunction operand, [bool negative = false]) : super(operand, negative);

  @override
  num call(Map<String, double> p) => _arcsch(operand(p)) * factor;

  @override
  bscFunction derivative(Variable v) =>
      (-operand.derivative(v) / (operand * root((operand ^ n(2)) + n(1))))
          .invertSign(negative);

  @override
  bscFunction withSign(bool negative) => ArCscH._(operand, negative);

}

double _arcsch(double v) => math.log(math.sqrt(1 + math.pow(v, 2)) / v);
