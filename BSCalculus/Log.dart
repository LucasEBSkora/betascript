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
    if (base is Number) {
      return operand.derivative(v)/(log(base)*operand).withSign(negative);
    }
    return (log(operand)/log(base)).derivative(v).withSign(negative);
  }

  @override
  num evaluate(Map<String, double> p) => math.log(operand.evaluate(p))/math.log(base.evaluate(p));
  
  @override 
  String toString([bool handleMinus = true]) {
    String s = (negative && handleMinus ? "-" : "");
    if (base == Number.e) {
      s += "ln(" + operand.toString() + ")";
    } else {
      s += "log(" + base.toString() + ")(" + operand.toString() + ")";
    }
    return s;
  }

  @override
  bscFunction withSign(bool negative) => Log(operand, base, negative);

}