import '../Variable.dart';
import '../bscFunction.dart';
import 'Sin.dart';
import 'dart:math';


class Cos extends bscFunction {

  final bscFunction operand;

  Cos(bscFunction this.operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => -Sin(operand)*(operand.derivative(v));

  @override
  num evaluate(Map<String, double> p) => cos(operand.evaluate(p));

  @override
  bscFunction ignoreNegative() => Cos(operand, false);

  @override
  bscFunction opposite() => Cos(operand, !negative);

  @override
  String toString([bool handleMinus = true]) => 'cos(' + operand.toString() + ')';

}