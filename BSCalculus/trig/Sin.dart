import '../Variable.dart';
import '../bscFunction.dart';
import 'Cos.dart';
import 'dart:math';


class Sin extends bscFunction {

  final bscFunction operand;

  Sin(bscFunction this.operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => (Cos(operand)*(operand.derivative(v))).invertSign(negative);

  @override
  num call(Map<String, double> p) => sin(operand(p));

  @override
  String toString([bool handleMinus = true]) => (negative ? '-' : '') + 'sin(' + operand.toString() + ')';

  @override
  bscFunction withSign(bool negative) => Sin(operand, negative);

}