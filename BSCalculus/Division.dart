import 'Multiplication.dart';
import 'Number.dart';
import 'bscFunction.dart';
import 'Variable.dart';

class Division extends bscFunction {
  final bscFunction numerator;
  final bscFunction denominator; 


  Division._(bscFunction this.numerator, bscFunction this.denominator, [bool negative = false]) : super(negative);

  static bscFunction create(List<bscFunction> numeratorList, List<bscFunction> denominatorList) {
    bool negative = false;


    bscFunction numerator = Multiplication.create(numeratorList);
    bscFunction denominator = Multiplication.create(denominatorList);
  
    if (numerator == Number(0)) return Number(0);

    return Division._(numerator, denominator, negative);
  }

  @override
  bscFunction derivative(Variable v) => (numerator.derivative(v)*denominator - denominator.derivative(v)*numerator)/(denominator^(Number(2)));

  @override
  num evaluate(Map<String, double> p) => numerator.evaluate(p)/denominator.evaluate(p);

  @override 
  String toString([bool handleMinus = true]) => (handleMinus && negative ? '-' : '') + '((' + numerator.toString() + ')/(' + denominator.toString() + '))';


  @override
  bscFunction withSign(bool negative) => Division._(numerator, denominator, negative);

}