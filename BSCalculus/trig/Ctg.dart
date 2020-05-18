import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math';

import 'Csc.dart';


class Ctg extends bscFunction {

  final bscFunction operand;

  Ctg(bscFunction this.operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => ((-Csc(operand)^Number(2))*operand.derivative(v)).invertSign(negative);

  @override
  num call(Map<String, double> p) => 1/tan(operand(p));

  @override
  String toString([bool handleMinus = true]) => 'ctg(' + operand.toString() + ')';

  @override
  bscFunction withSign(bool negative) => Ctg(operand, negative);

}