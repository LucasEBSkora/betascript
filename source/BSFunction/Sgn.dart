import 'Variable.dart';
import 'BSFunction.dart';
import 'Number.dart';
import 'dart:collection' show SplayTreeSet;

BSFunction sgn(BSFunction operand, [Set<Variable> params = null]) {
  return Signum._(operand, params);
}

class Signum extends BSFunction {
  
  final BSFunction operand;

  Signum._(BSFunction this.operand, Set<Variable> params) : super(params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand;
    if (op is Number) {
      if (op.value < 0) return n(-1);
      else if (op.value > 0) return n(1);
      else return n(0);
    } else return sgn(op);

  }

  //The derivativeInternal of the sign function is either 0 or undefined.
  @override
  BSFunction derivativeInternal(Variable v) => n(0);

  @override
  String toString([bool handleMinus = true])  => "sign($operand)";

  @override
  BSFunction copy([Set<Variable> params = null]) => Signum._(operand, params);

  SplayTreeSet<Variable> get defaultParameters => operand.parameters;

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) {
      if (op.value < 0) return n(-1);
      else if (op.value > 0) return n(1);
      else return n(0);
    } else return sgn(op);

  }

}

double sign(double v) {
  if (v == 0) return 0;
  else return ((v > 0) ? 1 : -1);
}