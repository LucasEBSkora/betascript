import '../Variable.dart';
import '../bscFunction.dart';
import 'Sin.dart';
import 'dart:math';


class Cos extends bscFunction {

  final bscFunction operand;

  Cos(bscFunction this.operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => (-Sin(operand)*(operand.derivative(v))).invertSign(negative);

  @override
  num call(Map<String, double> p) => cos(operand(p));

  @override
  String toString([bool handleMinus = true]) => (negative ? '-' : '') + 'cos(' + operand.toString() + ')';

  @override
  bscFunction withSign(bool negative) => Cos(operand, negative);

}