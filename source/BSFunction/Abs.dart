import 'dart:collection' show SplayTreeSet;

import 'Negative.dart';
import 'Number.dart';
import 'Sgn.dart';
import 'Variable.dart';
import 'BSFunction.dart';

BSFunction abs(BSFunction operand, [Set<Variable> params = null]) {
  //It makes no sense to keep a negative sign inside a absolute value.
  if (operand is Negative) operand = (operand as Negative).operand;

  //If the operand is a number, it can be returned directly, since it will always have the same absolute value
  if (operand is Number) return operand.copy(params);
  
  return AbsoluteValue._(operand, params);
}

class AbsoluteValue extends BSFunction {
  final BSFunction operand;

  AbsoluteValue._(BSFunction this.operand, Set<Variable> params)
      : super(params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) => abs(operand.evaluate(p));

  @override
  BSFunction derivativeInternal(Variable v) =>
      (sgn(operand) * operand.derivativeInternal(v));

  @override
  String toString([bool handleMinus = true]) => "|${operand}|";

  @override
  BSFunction copy([Set<Variable> params = null]) =>
      AbsoluteValue._(operand, params);

  @override
  SplayTreeSet<Variable> get defaultParameters => operand.defaultParameters;

  @override
  BSFunction get approx => abs(operand.approx);
}
