import 'dart:collection' show HashMap, SplayTreeSet;
import 'dart:math';

import 'log.dart';
import 'number.dart';
import 'variable.dart';
import 'βs_function.dart';

BSFunction exp(BSFunction exponent, [BSFunction base = constants.e]) {
  if (exponent == n(1)) return base;
  if (exponent == n(0)) return n(1);
  //if both exponent and base are numbers, but neither is named, performs the operation (so that 2^2 is displayed as 4 but pi^2 is still pi^2)
  if (exponent is Number &&
      base is Number &&
      !exponent.isNamed &&
      !base.isNamed) {
    return n(pow(base.value, exponent.value));
  } else
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
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction b = base.evaluate(p);
    BSFunction expo = exponent.evaluate(p);
    var pair = BSFunction.toNums(b, expo);
    if (pair.first != null && pair.second != null) {
      double v = pow(pair.first, pair.second);
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

    var pair = BSFunction.toNums(b, expo);
    if (pair.first == null || pair.second == null) {
      return exp(b, expo);
    } else {
      return n(pow(pair.first, pair.second));
    }
  }
}
