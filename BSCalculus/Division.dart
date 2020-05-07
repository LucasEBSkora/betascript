import 'Multiplication.dart';
import 'Number.dart';
import 'bscFunction.dart';
import 'Variable.dart';

class Division extends bscFunction {
  final bscFunction numerator;
  final bscFunction denominator; 


  Division._(bscFunction this.numerator, bscFunction this.denominator, [bool negative = false]) : super(negative);

  static bscFunction create(List<bscFunction> numerator, List<bscFunction> denominator) {
    bool negative = false;

    return Division._(Multiplication.create(numerator), Multiplication.create(denominator), negative);
  }

  @override
  bscFunction derivative(Variable v) => (numerator.derivative(v)*denominator - denominator.derivative(v)*numerator)/(denominator^(Number(2)));

  @override
  num evaluate(Map<String, double> p) => numerator.evaluate(p)/denominator.evaluate(p);

  @override 
  String toString([bool handleMinus = true]) => (handleMinus && negative ? '-' : '') + '((' + numerator.toString() + ')/(' + denominator.toString() + '))';

  @override
  bscFunction ignoreNegative() => Division._(numerator, denominator, false);

  @override
  bscFunction opposite() => Division._(numerator, denominator, !negative);

}