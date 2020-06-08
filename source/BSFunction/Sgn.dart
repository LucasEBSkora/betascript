import 'Variable.dart';
import 'bscFunction.dart';
import 'Number.dart';


bscFunction sgn(bscFunction operand, [bool negative = false]) {
  return Signum._(operand, negative);
}

class Signum extends bscFunction {
  
  final bscFunction operand;

  Signum._(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  double call(Map<String, double> p) => sign(operand(p))*factor;

  //The derivative of the sign function is either 0 or undefined.
  @override
  bscFunction derivative(Variable v) => n(0);

  @override
  String toString([bool handleMinus = true])  => "${minusSign(handleMinus)}sign($operand)";

  @override
  bscFunction withSign(bool negative) => Signum._(operand, negative);

  @override
  Set<Variable> get parameters => operand.parameters;

}

double sign(double v) {
  if (v == 0) return 0;
  else return ((v > 0) ? 1 : -1);
}