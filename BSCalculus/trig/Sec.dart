import '../Variable.dart';
import '../bscFunction.dart';
import 'Tan.dart';
import 'dart:math';


class Sec extends bscFunction {

  final bscFunction operand;

  Sec(bscFunction this.operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => (Sec(operand)*Tan(operand)*operand.derivative(v)).invertSign(negative);

  @override
  num call(Map<String, double> p) => 1/cos(operand(p));

  @override
  String toString([bool handleMinus = true]) => (negative ? '-' : '') + 'sec(' + operand.toString() + ')';

  @override
  bscFunction withSign(bool negative) => Sec(operand, negative);

}