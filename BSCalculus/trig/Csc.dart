import '../Variable.dart';
import '../bscFunction.dart';
import 'Ctg.dart';
import 'dart:math';


class Csc extends bscFunction {

  final bscFunction operand;

  Csc(bscFunction this.operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => -this*Ctg(operand);

  @override
  num call(Map<String, double> p) => 1/sin(operand(p));

  @override
  String toString([bool handleMinus = true]) => (negative ? '-' : '') + 'csc(' + operand.toString() + ')';

  @override
  bscFunction withSign(bool negative) => Csc(operand, negative);

}