import 'dart:collection' show HashMap, SplayTreeSet;

import 'number.dart';
import 'variable.dart';
import 'βs_function.dart';

BSFunction negative(BSFunction op) {
  if (op is Negative) return op.operand;
  if (op == n(0))
    return op;
  else
    return Negative._(op);
}

class Negative extends BSFunction {
  final BSFunction operand;

  const Negative._(this.operand, [Set<Variable> params]) : super(params);

  const Negative(this.operand) : super(null);

  @override
  BSFunction get approx => negative(operand.approx);

  @override
  BSFunction copy([Set<Variable> parameters]) =>
      Negative._(operand, parameters);

  @override
  SplayTreeSet<Variable> get defaultParameters => operand.parameters;

  @override
  BSFunction derivativeInternal(Variable v) => negative(operand.derivative(v));

  @override
  String toString() => "-$operand";

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) =>
      negative(operand.evaluate(p));
}
