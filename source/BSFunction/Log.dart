import 'dart:math' as math;
import 'dart:collection' show SplayTreeSet;

import 'Number.dart';
import 'Variable.dart';
import 'BSFunction.dart';

BSFunction log(BSFunction operand,
    [BSFunction base = constants.e, Set<Variable> params = null]) {
  //log_a(1) == 0 for every a
  if (operand == n(1))
    return n(0);
  //log_a(a) == 1 for every a
  else if (operand == base)
    return n(1);
  else
    return Log._(operand, base, params);
}

class Log extends BSFunction {
  final BSFunction base;
  final BSFunction operand;

  Log._(this.operand, this.base, Set<Variable> params) : super(params);

  @override
  BSFunction derivativeInternal(Variable v) {
    if (base is Number)
      return (operand.derivativeInternal(v) / (log(base) * operand));

    //if base is also a function, uses log_b(a) = ln(a)/ln(b) s
    return ((log(operand) / log(base)).derivativeInternal(v));
  }

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction b = base.evaluate(p);
    BSFunction op = operand.evaluate(p);
    if (b is Number && op is Number) {
      //if both are numbers, checks if the evaluation is a integer. if it is, returns the integer.
      double v = math.log(b.value) / math.log(b.value);
      if (v == v.toInt()) return n(v);
    }
    return log(b, op);
  }

  @override
  String toString([bool handleMinus = true]) {
    if (base == constants.e)
      return "ln($operand)";
    else
      return "log($base)($operand)";
  }

  @override
  BSFunction copy([Set<Variable> params = null]) =>
      Log._(operand, base, params);

  @override
  SplayTreeSet<Variable> get defaultParameters {
    Set<Variable> params = base.parameters;
    params.addAll(operand.parameters);
    return params;
  }

  @override
  BSFunction get approx {
    BSFunction b = base.approx;
    BSFunction op = operand.approx;
    if (b is Number && op is Number)
      return n(math.log(b.value) / math.log(b.value));
    return log(b, op);
  }
}
