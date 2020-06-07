import 'Exponentiation.dart';
import 'Number.dart';
import 'Variable.dart';
import 'bscFunction.dart';
import 'dart:math' as math;

//TODO: Implement roots that aren't square roots

bscFunction root(bscFunction operand, [bool negative = false]) {
  if (operand is Exponentiation) 
    return (operand.base^(operand.exponent/n(2))).invertSign(negative);
  else return Root._(operand, negative);
}

class Root extends bscFunction {
  final bscFunction operand;

  Root._(this.operand, [bool negative = false]) : super(negative);


  @override
  bscFunction derivative(Variable v) => (n(1/2)*(operand^n(-1/2))*operand.derivative(v)).invertSign(negative);

  @override
  num call(Map<String, double> p) => math.sqrt(operand(p))*factor;
  
  @override 
  String toString([bool handleMinus = true]) => "${minusSign(handleMinus)}sqrt($operand)";
  
  @override
  bscFunction withSign(bool negative) => Root._(operand, negative);

}