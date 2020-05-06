import 'Variable.dart';
import 'bscFunction.dart';
import 'dart:math';
import 'Number.dart';

class Exponentiation extends bscFunction {
  final bscFunction _base;
  final bscFunction _exponent;

  Exponentiation._(this._exponent, [this._base = Number.e, negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) {
    
    return null;
  }

  @override
  num evaluate(Map<String, double> p) {
    return pow(_base.evaluate(p), _exponent.evaluate(p));
  }

  @override
  bscFunction ignoreNegative() {
    return Exponentiation._(_base, _exponent, false);
  }

  @override
  bscFunction opposite() {
    return Exponentiation._(_base, _exponent, !negative);
  }

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
    '(' + _base.toString() + ')^' +
    '(' + _exponent.toString() + ')';
  }

}