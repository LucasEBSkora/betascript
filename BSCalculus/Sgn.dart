import 'Variable.dart';
import 'bscFunction.dart';
import 'Number.dart';

class Sgn extends bscFunction {
  
  final bscFunction operand;

  Sgn(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  double call(Map<String, double> p) => sign(operand(p));

  //The derivative of the sign function is either 0 or undefined.
  @override
  bscFunction derivative(Variable v) => Number(0);

  @override
  String toString([bool handleMinus = true]) => ((handleMinus && negative) ? '-' : '') + 'sgn(' + operand.toString() + ')';

  @override
  bscFunction withSign(bool negative) => Sgn(operand, negative);

}

double sign(double v) {
  if (v == 0) return 0;
  else return ((v > 0) ? 1 : -1);
}