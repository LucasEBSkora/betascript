import '../Variable.dart';
import '../bscFunction.dart';
import 'Cos.dart';
import 'dart:math';


class Sin extends bscFunction {

  final bscFunction _operand;

  Sin(bscFunction this._operand, [negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) {
    
    return Cos(_operand)*(_operand.derivative(v));
  }

  @override
  num evaluate(Map<String, double> p) {
    return sin(_operand.evaluate(p));
  }

  @override
  bscFunction ignoreNegative() {
    return Sin(_operand, false);
  }

  @override
  bscFunction opposite() {
    return Sin(_operand, !negative);
  }

  @override
  String toString([bool handleMinus = true]) {
    return 'sin(' + _operand.toString() + ')';
  }

}