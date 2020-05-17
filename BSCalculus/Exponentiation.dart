import 'Log.dart';
import 'Variable.dart';
import 'bscFunction.dart';
import 'dart:math';
import 'Number.dart';

class Exponentiation extends bscFunction {
  final bscFunction base;
  final bscFunction exponent;

  Exponentiation._(this.exponent, [this.base = Number.e, negative = false]) : super(negative);

  static bscFunction create(bscFunction exponent, [bscFunction base = Number.e, negative = false]) {
    if (exponent == Number(1)) return base.withSign(negative);
    
    else if (exponent is Number && base is Number && !exponent.isNamed && !base.isNamed) return Number(pow(base.value, exponent.value)).withSign(negative); 
    else return Exponentiation._(exponent, base, negative);
  }

  @override
  bscFunction derivative(Variable v) => (base^exponent)*(exponent*(log(base).derivative(v)) + exponent.derivative(v)*log(base));

  @override
  num evaluate(Map<String, double> p) => pow(base.evaluate(p), exponent.evaluate(p));

  @override
  String toString([bool handleMinus = true]) {

    return (handleMinus && negative ? '-' : '') +
    '((' + base.toString() + ')^' +
    '(' + exponent.toString() + '))';
  }

  @override
  bscFunction withSign(bool negative) => Exponentiation._(base, exponent, negative);

}

// (((x)^(x))*(((((x)/(0)) - (ln(x)*((((1)^(e)))/(0)))))/(((2)^(e)))))