import 'dart:collection';

import 'BSFunction.dart';
import 'Number.dart';
import 'Variable.dart';

BSFunction negative(BSFunction op) {
  if (op is Negative)
    return op.operand;
  if (op == n(0))
    return op;
  else
    return Negative._(op, null);
}

class Negative extends BSFunction {
  final BSFunction operand;

  Negative._(BSFunction this.operand, Set<Variable> params) : super(params);

  @override
  BSFunction get approx => negative(operand.approx);

  @override
  BSFunction copy([Set<Variable> parameters = null]) =>
      Negative._(operand, parameters);

  @override
  SplayTreeSet<Variable> get defaultParameters => operand.parameters;

  @override
  BSFunction derivativeInternal(Variable v) => negative(operand.derivative(v));

  @override
  String toString([bool handleMinus = true]) => "-${operand}";

  @override
  BSFunction evaluate(Map<String, BSFunction> p) => negative(operand.evaluate(p));
}
