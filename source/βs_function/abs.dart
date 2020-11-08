import 'dart:collection' show HashMap, SplayTreeSet;

import 'negative.dart';
import 'number.dart';
import 'sgn.dart';
import 'variable.dart';
import 'βs_function.dart';

BSFunction abs(BSFunction operand) {
  //It makes no sense to keep a negative sign inside a absolute value.
  if (operand is Negative) operand = (operand as Negative).operand;

  //If the operand is a number, it can be returned directly, since it will always have the same absolute value
  if (operand is Number) return operand;

  return AbsoluteValue._(operand);
}

class AbsoluteValue extends BSFunction {
  final BSFunction operand;

  const AbsoluteValue._(this.operand, [Set<Variable> params]) : super(params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) =>
      abs(operand.evaluate(p));

  @override
  BSFunction derivativeInternal(Variable v) =>
      (sgn(operand) * operand.derivativeInternal(v));

  @override
  String toString() => "|$operand|";

  @override
  BSFunction copy([Set<Variable> params]) => AbsoluteValue._(operand, params);

  @override
  SplayTreeSet<Variable> get defaultParameters => operand.defaultParameters;

  @override
  BSFunction get approx => abs(operand.approx);
}
