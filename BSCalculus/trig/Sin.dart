import '../Variable.dart';
import '../bscFunction.dart';
import 'Cos.dart';
import 'dart:math';


class Sin extends bscFunction {

  final bscFunction operand;

  Sin(bscFunction this.operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => Cos(operand).withSign(negative)*(operand.derivative(v));

  @override
  num evaluate(Map<String, double> p) => sin(operand.evaluate(p));

  @override
  String toString([bool handleMinus = true]) => (negative ? '-' : '') + 'sin(' + operand.toString() + ')';

  @override
  bscFunction withSign(bool negative) => Sin(operand, negative);

}