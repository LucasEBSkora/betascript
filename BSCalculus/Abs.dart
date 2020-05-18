import 'Sgn.dart';
import 'Variable.dart';
import 'bscFunction.dart';
import 'Number.dart';

bscFunction abs(bscFunction operand, [bool negative = false]) {
  if (operand is Number) return operand.withSign(negative);
  else return AbsoluteValue(operand, negative);
}

class AbsoluteValue extends bscFunction {
  
  final bscFunction operand;

  AbsoluteValue(bscFunction this.operand, [bool negative = false]) : super(negative);

  @override
  double call(Map<String, double> p) => (operand(p)).abs();

  @override
  bscFunction derivative(Variable v) => (Sgn(operand)*operand.derivative(v)).invertSign(negative);

  @override
  String toString([bool handleMinus = true]) => ((handleMinus && negative) ? '-' : '') + '|' + operand.toString() + '|';

  @override
  bscFunction withSign(bool negative) => AbsoluteValue(operand, negative);

}
