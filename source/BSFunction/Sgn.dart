import 'Variable.dart';
import 'BSFunction.dart';
import 'Number.dart';
import 'dart:collection' show SplayTreeSet;

BSFunction sgn(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  return Signum._(operand, negative, params);
}

class Signum extends BSFunction {
  
  final BSFunction operand;

  Signum._(BSFunction this.operand, bool negative, Set<Variable> params) : super(negative, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
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
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => Signum._(operand, negative, params);

  SplayTreeSet<Variable> get minParameters => operand.parameters;

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