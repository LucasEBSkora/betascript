import 'dart:math' as math;

import 'Number.dart';
import 'Variable.dart';
import 'bscFunction.dart';

bscFunction log(bscFunction operand,
    [bscFunction base = constants.e, negative = false]) {
  //log_a(1) == 0 for every a
  if (operand == n(1))
    return n(0);
  //log_a(a) == 1 for every a
  else if (operand == base)
    return n(1);
  else
    return Log._(operand, base, negative);
}

class Log extends bscFunction {
  final bscFunction base;
  final bscFunction operand;

  Log._(this.operand, [this.base = constants.e, negative = false])
      : super(negative);

  @override
  bscFunction derivative(Variable v) {
    if (base is Number) {
      return (operand.derivative(v) / (log(base) * operand))
          .invertSign(negative);
    }

    //if base is also a function, uses log_b(a) = ln(a)/ln(b) s
    return ((log(operand) / log(base)).derivative(v)).invertSign(negative);
  }

  @override
  num call(Map<String, double> p) =>
      math.log(operand(p)) / math.log(base(p)) * factor;

  @override
  String toString([bool handleMinus = true]) {
    if (base == constants.e)
      return "${minusSign(handleMinus)}ln($operand)";
    else
      return "${minusSign(handleMinus)}log($base)($operand)";
  }

  @override
  bscFunction withSign(bool negative) => Log._(operand, base, negative);
}
