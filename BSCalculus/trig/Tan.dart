import '../Number.dart';
import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math';

import 'Sec.dart';


class Tan extends bscFunction {

  final bscFunction operand;

  Tan(bscFunction this.operand, [negative = false]) : super(negative);
  
  @override
  bscFunction derivative(Variable v) => (Sec(operand)^Number(2)).withSign(negative);

  @override
  num call(Map<String, double> p) => tan(operand(p));

  @override
  String toString([bool handleMinus = true]) => 'tan(' + operand.toString() + ')';

  @override
  bscFunction withSign(bool negative) => Tan(operand, negative);

}