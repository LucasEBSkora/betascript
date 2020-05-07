import '../Variable.dart';
import '../bscFunction.dart';
import 'Cos.dart';
import 'dart:math';


class Sin extends bscFunction {

  final bscFunction operand;

  Sin(bscFunction this.operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) => Cos(operand)*(operand.derivative(v));

  @override
  num evaluate(Map<String, double> p) => sin(operand.evaluate(p));

  @override
  bscFunction ignoreNegative() => Sin(operand, false);

  @override
  bscFunction opposite() => Sin(operand, !negative);

  @override
  String toString([bool handleMinus = true]) => 'sin(' + operand.toString() + ')';

}