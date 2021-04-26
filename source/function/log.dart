import 'dart:math' as math;
import 'dart:collection' show HashMap, SplayTreeSet;

import 'function.dart';
import 'visitors/function_visitor.dart';
import 'number.dart';
import 'variable.dart';

BSFunction log(BSFunction operand, [BSFunction base = Constants.e]) {
  //log_a(1) == 0 for every a
  if (operand == n(1)) {
    return n(0);
  }
  //log_a(a) == 1 for every a
  else if (operand == base) {
    return n(1);
  } else {
    return Log._(operand, base);
  }
}

class Log extends BSFunction {
  final BSFunction base;
  final BSFunction operand;

  const Log._(this.operand, this.base, [Set<Variable> params = const <Variable>{}]) : super(params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final b = base.evaluate(p);
    final op = operand.evaluate(p);
    if (b is Number && op is Number) {
      //if both are numbers, checks if the evaluation is a integer. if it is, returns the integer.
      double v = math.log(op.value) / math.log(b.value);

      if (v == v.toInt()) return n(v);
    }
    return log(op, b);
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => Log._(operand, base, params);

  @override
  SplayTreeSet<Variable> get defaultParameters => SplayTreeSet<Variable>.from(
      <Variable>{...base.parameters, ...operand.parameters});

  @override
  BSFunction get approx {
    final b = base.approx;
    final op = operand.approx;
    return (b is Number && op is Number)
        ? n(math.log(op.value) / math.log(b.value))
        : log(op, b);
  }

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitLog(this);
}
