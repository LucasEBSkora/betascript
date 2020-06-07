import 'Log.dart';
import 'Variable.dart';
import 'bscFunction.dart';
import 'dart:math';
import 'Number.dart';

bscFunction exp(bscFunction exponent,
    [bscFunction base = constants.e, negative = false]) {
  if (exponent == n(1)) return base.invertSign(negative);
  if (exponent == n(0)) return n(1);
  //if both exponent and base are numbers, but neither is named, performs the operation (so that 2^2 is displayed as 4 but pi^2 is still pi^2)
  if (exponent is Number &&
      base is Number &&
      !exponent.isNamed &&
      !base.isNamed)
    return n(pow(base.value, exponent.value)).withSign(negative);
  else
    return Exponentiation._(exponent, base, negative);
}

class Exponentiation extends bscFunction {
  final bscFunction base;
  final bscFunction exponent;

  Exponentiation._(this.exponent, [this.base = constants.e, negative = false])
      : super(negative);

  @override
  bscFunction derivative(Variable v) {
    return ((base ^ exponent) *
            (exponent * (log(base).derivative(v)) +
                exponent.derivative(v) * log(base)))
        .invertSign(negative);
  }

  @override
  num call(Map<String, double> p) => pow(base(p), exponent(p)) * factor;

  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}(($base)^($exponent))";

  @override
  bscFunction withSign(bool negative) =>
      Exponentiation._(exponent, base, negative);
}
