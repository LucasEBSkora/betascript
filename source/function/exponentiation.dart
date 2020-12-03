import 'dart:collection' show HashMap, SplayTreeSet;
import 'dart:math';

import 'log.dart';
import 'number.dart';
import 'variable.dart';
import 'function.dart';

BSFunction exp(BSFunction exponent, [BSFunction base = Constants.e]) {
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

  const Exponentiation._(this.exponent, this.base, [Set<Variable> params])
      : super(params);

  @override
  BSFunction derivativeInternal(Variable v) {
    return ((base ^ exponent) *
        (exponent * (log(base).derivativeInternal(v)) +
            exponent.derivativeInternal(v) * log(base)));
  }

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final b = base.evaluate(p);
    final expo = exponent.evaluate(p);
    final pair = BSFunction.toNums(b, expo);
    if (pair != null) {
      double v = pow(pair.first, pair.second);
      if (v == v.toInt()) return n(v);
    }

    return exp(b, expo);
  }

  @override
  String toString() => "(($base)^($exponent))";

  BSFunction copy([Set<Variable> params]) =>
      Exponentiation._(exponent, base, params);

  @override
  SplayTreeSet<Variable> get defaultParameters => SplayTreeSet<Variable>.from(
      <Variable>{...base.parameters, ...exponent.parameters});

  @override
  BSFunction get approx {
    final b = base.approx;
    final expo = exponent.approx;

    final pair = BSFunction.toNums(b, expo);
    if (pair == null) {
      return exp(b, expo);
    } else {
      return n(pow(pair.first, pair.second));
    }
  }
}
