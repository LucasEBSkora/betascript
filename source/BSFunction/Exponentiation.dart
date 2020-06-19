import 'Log.dart';
import 'Variable.dart';
import 'BSFunction.dart';
import 'dart:math';
import 'Number.dart';

BSFunction exp(BSFunction exponent,
    [BSFunction base = constants.e, negative = false]) {
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

class Exponentiation extends BSFunction {
  final BSFunction base;
  final BSFunction exponent;

  Exponentiation._(this.exponent, [this.base = constants.e, negative = false])
      : super(negative);

  @override
  BSFunction derivative(Variable v) {
    return ((base ^ exponent) *
            (exponent * (log(base).derivative(v)) +
                exponent.derivative(v) * log(base)))
        .invertSign(negative);
  }

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction b = base(p);
    BSFunction expo = exponent(p);
    if (b is Number && expo is Number) {
      double v = pow(b.value, expo.value) * factor;
      if (v == v.toInt()) return n(v);
    }
    return exp(b, expo, negative);
  }

  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}(($base)^($exponent))";

  BSFunction withSign(bool negative) =>
      Exponentiation._(exponent, base, negative);

  @override
  Set<Variable> get parameters {
    Set<Variable> params = base.parameters;
    params.addAll(exponent.parameters);
    return params;
  }

  @override
  BSFunction get approx {
    BSFunction b = base.approx;
    BSFunction expo = exponent.approx;
    if (b is Number && expo is Number)
      return n(pow(b.value, expo.value) * factor);

    return exp(b, expo, negative);
  }
}
