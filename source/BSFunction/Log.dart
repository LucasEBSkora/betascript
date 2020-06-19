import 'dart:math' as math;

import 'Number.dart';
import 'Variable.dart';
import 'BSFunction.dart';

BSFunction log(BSFunction operand,
    [BSFunction base = constants.e, negative = false]) {
  //log_a(1) == 0 for every a
  if (operand == n(1))
    return n(0);
  //log_a(a) == 1 for every a
  else if (operand == base)
    return n(1);
  else
    return Log._(operand, base, negative);
}

class Log extends BSFunction {
  final BSFunction base;
  final BSFunction operand;

  Log._(this.operand, [this.base = constants.e, negative = false])
      : super(negative);

  @override
  BSFunction derivative(Variable v) {
    if (base is Number) {
      return (operand.derivative(v) / (log(base) * operand))
          .invertSign(negative);
    }

    //if base is also a function, uses log_b(a) = ln(a)/ln(b) s
    return ((log(operand) / log(base)).derivative(v)).invertSign(negative);
  }

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction b = base(p);
    BSFunction op = operand(p);
    if (b is Number && op is Number) {
      //if both are numbers, checks if the evaluation is a integer. if it is, returns the integer.
      double v = math.log(b.value) / math.log(b.value) * factor;
      if (v == v.toInt()) return n(v);
    }
    return log(b, op, negative);
  }

  @override
  String toString([bool handleMinus = true]) {
    if (base == constants.e)
      return "${minusSign(handleMinus)}ln($operand)";
    else
      return "${minusSign(handleMinus)}log($base)($operand)";
  }

  @override
  BSFunction withSign(bool negative) => Log._(operand, base, negative);

  @override
  Set<Variable> get parameters {
    Set<Variable> params = base.parameters;
    params.addAll(operand.parameters);
    return params;
  }

  @override
  BSFunction get approx {
    BSFunction b = base.approx;
    BSFunction op = operand.approx;
    if (b is Number && op is Number)
      return n(math.log(b.value) / math.log(b.value) * factor);
    return log(b, op, negative);
  }
}
