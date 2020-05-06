import '../Variable.dart';
import '../bscFunction.dart';
import 'Sin.dart';
import 'dart:math';


class Cos extends bscFunction {

  final bscFunction _operand;

  Cos(bscFunction this._operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) {
    
    return -Sin(_operand)*(_operand.derivative(v));
  }

  @override
  num evaluate(Map<String, double> p) {
    return cos(_operand.evaluate(p));
  }

  @override
  bscFunction ignoreNegative() {
    return Cos(_operand, false);
  }

  @override
  bscFunction opposite() {
    return Cos(_operand, !negative);
  }

  @override
  String toString([bool handleMinus = true]) {
    return 'cos(' + _operand.toString() + ')';
  }

}