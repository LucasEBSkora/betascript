
import 'Number.dart';
import 'Variable.dart';
import 'bscFunction.dart';
import 'dart:math' as math;

//TODO: Implement roots that aren't square roots

class Root extends bscFunction {
  final bscFunction operand;

  Root(this.operand, [negative = false]) : super(negative);


  @override
  bscFunction derivative(Variable v) => (Number(1/2)*(operand^Number(-1/2))*operand.derivative(v)).invertSign(negative);

  @override
  num call(Map<String, double> p) => math.sqrt(operand(p));
  
  @override 
  String toString([bool handleMinus = true]) => (negative && handleMinus ? "-" : "") + 'sqrt(' + operand.toString() + ')';
  
  @override
  bscFunction withSign(bool negative) => Root(operand, negative);

}