import 'dart:collection' show HashMap, SplayTreeSet;

import 'abs.dart';
import 'number.dart';
import 'variable.dart';
import 'βs_function.dart';

BSFunction sgn(BSFunction operand) {
  final _f1 = BSFunction.extractFromNegative<Number>(operand);
  if (_f1.second) {
    return (_f1.first.value == 0) ? n(0) : n(_f1.third ? -1 : 1);
  }

  final _f2 = BSFunction.extractFromNegative<AbsoluteValue>(operand);
  if (_f2.second) return n(_f2.third ? -1 : 1);

  return Signum._(operand);
}

class Signum extends BSFunction {
  final BSFunction operand;

  const Signum._(this.operand, [Set<Variable> params]) : super(params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) =>
      sgn(operand.evaluate(p));

  //The derivative of the sign function is either 0 or undefined.
  @override
  BSFunction derivativeInternal(Variable v) => n(0);

  @override
  String toString() => "sign($operand)";

  @override
  BSFunction copy([Set<Variable> params]) => Signum._(operand, params);

  SplayTreeSet<Variable> get defaultParameters => operand.parameters;

  @override
  BSFunction get approx => sgn(operand.approx);
}

double sign(double v) {
  return (v == 0) ? 0 : ((v > 0) ? 1 : -1);
}
