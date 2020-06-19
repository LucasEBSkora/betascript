import 'Variable.dart';
import 'BSFunction.dart';
import 'Number.dart';


BSFunction sgn(BSFunction operand, [bool negative = false]) {
  return Signum._(operand, negative);
}

class Signum extends BSFunction {
  
  final BSFunction operand;

  Signum._(BSFunction this.operand, [bool negative = false]) : super(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand;
    if (op is Number) {
      if (op.value < 0) return n(-1*factor);
      else if (op.value > 0) return n(1*factor);
      else return n(0);
    } else return sgn(op, negative);

  }

  //The derivative of the sign function is either 0 or undefined.
  @override
  BSFunction derivative(Variable v) => n(0);

  @override
  String toString([bool handleMinus = true])  => "${minusSign(handleMinus)}sign($operand)";

  @override
  BSFunction withSign(bool negative) => Signum._(operand, negative);

  Set<Variable> get parameters => operand.parameters;

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) {
      if (op.value < 0) return n(-1);
      else if (op.value > 0) return n(1);
      else return n(0);
    } else return sgn(op, negative);

  }

}

double sign(double v) {
  if (v == 0) return 0;
  else return ((v > 0) ? 1 : -1);
}