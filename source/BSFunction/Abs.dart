import 'dart:collection' show SplayTreeSet;

import 'Sgn.dart';
import 'Variable.dart';
import 'BSFunction.dart';
import 'Number.dart';

BSFunction abs(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is Number) return operand.copy(negative, params);
  else return AbsoluteValue._(operand, negative, params);
}

class AbsoluteValue extends BSFunction {
  
  final BSFunction operand;

  AbsoluteValue._(BSFunction this.operand, bool negative, Set<Variable> params) : super(negative, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) return op.ignoreNegative;
    else return abs(op, negative);
  }

  @override
  BSFunction derivative(Variable v) => (sgn(operand)*operand.derivative(v)).invertSign(negative);

  @override
  String toString([bool handleMinus = true]) => "${minusSign(handleMinus)}|${operand}|";

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => AbsoluteValue._(operand, negative, params);

  @override
  SplayTreeSet<Variable> get minParameters => operand.minParameters;

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return op.ignoreNegative;
    else return abs(op, negative);
  }

}
