import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math';


class Tan extends bscFunction {

  final bscFunction operand;

  Tan(bscFunction this.operand, [negative = false]) : super(negative);

  //TODO: implement derivative of Tangent (needs Exponentiation and Secant)
  @override
  bscFunction derivative(Variable v) => null;

  @override
  num evaluate(Map<String, double> p) => tan(operand.evaluate(p));

  @override
  bscFunction ignoreNegative() => Tan(operand, false);

  @override
  bscFunction opposite() => Tan(operand, !negative);

  @override
  String toString([bool handleMinus = true]) => 'Tan(' + operand.toString() + ')';

}