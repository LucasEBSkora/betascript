import '../Abs.dart';
import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math' as math;

bscFunction arcsec(bscFunction operand, [bool negative = false]) {
  if (operand is Sec)
    return operand.operand.invertSign(negative);
  else
    return ArcSec._(operand, negative);
}


class ArcSec extends bscFunction {
  final bscFunction operand;

  ArcSec._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  num call(Map<String, double> p) => math.acos(1 / operand(p))*factor;

  @override
  bscFunction derivative(Variable v) => (operand.derivative(v)/(abs(operand)*root((operand^n(2)) - n(1)))).invertSign(negative);


  @override
  bscFunction withSign(bool negative) => ArcSec._(operand, negative);

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
        'arcsec(' +
        operand.toString() +
        ')';
  }
}
