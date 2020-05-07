import 'dart:math' as math;

import 'Number.dart';
import 'Variable.dart';
import 'bscFunction.dart';


bscFunction log(bscFunction operand, [bscFunction base = Number.e, negative = false]) {
  if (operand == Number(1)) return Number(0);
  else if (operand == base) return Number(1);
  else return Log(operand, base, negative);
}

class Log extends bscFunction {
  final bscFunction base;
  final bscFunction operand;

  Log(this.operand, [this.base = Number.e, negative = false]) : super(negative);


  @override
  bscFunction derivative(Variable v) {
    return ((operand/operand.derivative(v))*log(base) - log(operand)*(base/base.derivative(v)))/(base^Number(2));
  }

  @override
  num evaluate(Map<String, double> p) => math.log(operand.evaluate(p))/math.log(base.evaluate(p));

  @override
  bscFunction ignoreNegative() => Log(operand, base, false);

  @override
  bscFunction opposite() => Log(operand, base, !negative);

  @override 
  String toString([bool handleMinus = true]) => null;

}