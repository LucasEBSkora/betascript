import 'Log.dart';
import 'Variable.dart';
import 'BSFunction.dart';
import 'dart:math';
import 'Number.dart';
import 'dart:collection' show SplayTreeSet;

BSFunction exp(BSFunction exponent,
    [BSFunction base = constants.e]) {
  if (exponent == n(1)) return base;
  if (exponent == n(0)) return n(1);
  //if both exponent and base are numbers, but neither is named, performs the operation (so that 2^2 is displayed as 4 but pi^2 is still pi^2)
  if (exponent is Number &&
      base is Number &&
      !exponent.isNamed &&
      !base.isNamed)
    return n(pow(base.value, exponent.value));
  else
    return Exponentiation._(exponent, base);
}

class Exponentiation extends BSFunction {
  final BSFunction base;
  final BSFunction exponent;

  Exponentiation._(this.exponent, this.base, [Set<Variable> params = null])
      : super(params);

  @override
  BSFunction derivativeInternal(Variable v) {

    return ((base ^ exponent) *
        (exponent * (log(base).derivativeInternal(v)) +
            exponent.derivativeInternal(v) * log(base)));
  }

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction b = base.evaluate(p);
    BSFunction expo = exponent.evaluate(p);
    if (b is Number && expo is Number) {
      double v = pow(b.value, expo.value);
      if (v == v.toInt()) return n(v);
    }
    return exp(b, expo);
  }

  @override
  String toString([bool handleMinus = true]) => "(($base)^($exponent))";

  BSFunction copy([Set<Variable> params = null]) =>
      Exponentiation._(exponent, base, params);

  @override
  SplayTreeSet<Variable> get defaultParameters {
    Set<Variable> params = base.parameters;
    params.addAll(exponent.parameters);
    return params;
  }

  @override
  BSFunction get approx {
    BSFunction b = base.approx;
    BSFunction expo = exponent.approx;
    if (b is Number && expo is Number) return n(pow(b.value, expo.value));

    return exp(b, expo);
  }
}
