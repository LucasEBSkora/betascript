import 'Variable.dart';
import 'bscFunction.dart';
import 'dart:math';
import 'Number.dart';

class Exponentiation extends bscFunction {
  final bscFunction base;
  final bscFunction exponent;

  Exponentiation(this.exponent, [this.base = Number.e, negative = false]) : super(negative);

  @override
  bscFunction derivative(Variable v) {
    
    return null;
  }

  @override
  num evaluate(Map<String, double> p) => pow(base.evaluate(p), exponent.evaluate(p));

  @override
  bscFunction ignoreNegative() => Exponentiation(base, exponent, false);

  @override
  bscFunction opposite() => Exponentiation(base, exponent, !negative);

  @override
  String toString([bool handleMinus = true]) {
    return (handleMinus && negative ? '-' : '') +
    '(' + base.toString() + ')^' +
    '(' + exponent.toString() + ')';
  }

}