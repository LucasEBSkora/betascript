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

    _eliminateDuplicates(numeratorList, denominatorList);

    _openMultiplicationsAndDivisions(numeratorList, denominatorList);
    
        bscFunction numerator = Multiplication.create(numeratorList);
        bscFunction denominator = Multiplication.create(denominatorList);
    
        if (numerator == denominator) return Number(1);
        if (numerator == Number(0)) return Number(0);
    
        return Division._(numerator, denominator, negative);
      }
    
      static void _eliminateDuplicates(List<bscFunction> numeratorList, List<bscFunction> denominatorList) {
        int i = 0;
        while (i < numeratorList.length) {
          bool remove = false;
          int j = 0;
          while (j < denominatorList.length) {
            if (numeratorList[i] == denominatorList[j]) {
              remove = true;
              denominatorList.removeAt(j);
            } else ++j;
          }
          if (remove) numeratorList.removeAt(i);
          else ++i;
        }
      }

      //TODO: implement _openMultiplicationsAndDivisions    
      // static void _openMultiplicationsAndDivisions(List<bscFunction> numeratorList, List<bscFunction> denominatorList) {
      //   for (int i = 0; i < numeratorList.length;) {
      //     bscFunction f = numeratorList[i];
      //     if ( )
      //   }
      // }

      @override
      bscFunction derivative(Variable v) => (numerator.derivative(v)*denominator - denominator.derivative(v)*numerator)/(denominator^(Number(2)));
    
      @override
      num evaluate(Map<String, double> p) => numerator.evaluate(p)/denominator.evaluate(p);
    
      @override 
      String toString([bool handleMinus = true]) => (handleMinus && negative ? '-' : '') + '((' + numerator.toString() + ')/(' + denominator.toString() + '))';
    
    
      @override
      bscFunction withSign(bool negative) => Division._(numerator, denominator, negative);

}