import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

import '../inverseTrig/inverseTrig.dart';
import 'Csc.dart';

bscFunction ctg(bscFunction operand, [bool negative = false]) {
  if (operand is ArcCtg)
    return operand.operand.invertSign(negative);
  else
    return Ctg._(operand, negative);
}

class Ctg extends bscFunction {

  final bscFunction operand;

  Ctg._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => ((-csc(operand)^n(2))*operand.derivative(v)).invertSign(negative);

  @override
  num call(Map<String, double> p) => 1/math.tan(operand(p));

  @override
  String toString([bool handleMinus = true]) => 'ctg(' + operand.toString() + ')';

  @override
  bscFunction withSign(bool negative) => Ctg._(operand, negative);

}