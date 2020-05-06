import '../Variable.dart';
import '../bscFunction.dart';
import 'dart:math';


class Tan extends bscFunction {

  final bscFunction _operand;

  Tan(bscFunction this._operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) {
    //TODO: implement derivative of Tangent (needs Exponentiation and Secant)
    return null;
  }

  @override
  num evaluate(Map<String, double> p) {
    return tan(_operand.evaluate(p));
  }

  @override
  bscFunction ignoreNegative() {
    return Tan(_operand, false);
  }

  @override
  bscFunction opposite() {
    return Tan(_operand, !negative);
  }

  @override
  String toString([bool handleMinus = true]) {
    return 'Tan(' + _operand.toString() + ')';
  }

}