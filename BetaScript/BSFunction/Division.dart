import 'Exponentiation.dart';
import 'Multiplication.dart';
import 'Number.dart';
import 'bscFunction.dart';
import 'Variable.dart';

bscFunction divide(
    List<bscFunction> numeratorList, List<bscFunction> denominatorList) {
  bool negative = false;

  _openMultiplicationsAndDivisions(numeratorList, denominatorList);
  _createExponents(numeratorList);
  _createExponents(denominatorList);
  _eliminateDuplicates(numeratorList, denominatorList);

  bscFunction numerator = multiply(numeratorList);

  if (denominatorList.length == 0) return numerator;

  bscFunction denominator = multiply(denominatorList);

  if (numerator == denominator) return n(1);
  if (numerator == n(0)) return n(0);

  return Division._(numerator, denominator, negative);
}

class Division extends bscFunction {
  final bscFunction numerator;
  final bscFunction denominator;

  Division._(bscFunction this.numerator, bscFunction this.denominator,
      [bool negative = false])
      : super(negative);

  @override
  bscFunction derivative(Variable v) {
    return ((numerator.derivative(v) * denominator -
                denominator.derivative(v) * numerator) /
            (denominator ^ (n(2))))
        .invertSign(negative);
  }

  @override
  num call(Map<String, double> p) => (numerator(p) / denominator(p))*factor;

  @override
  String toString([bool handleMinus = true]) => "${minusSign(handleMinus)}(($numerator)/($denominator))";

  @override
  bscFunction withSign(bool negative) =>
      Division._(numerator, denominator, negative);
}

///Cancels out identical factors in the numerator and denominator lists, also opening exponentiations when possible
void _eliminateDuplicates(
    List<bscFunction> numeratorList, List<bscFunction> denominatorList) {
  for (int i = 0; i < numeratorList.length; ++i) {
    //for each operand in the numerator, divides it into base and exponent, event if the exponent is 1
    bscFunction f = numeratorList[i];

    bscFunction base;
    bscFunction exponent;

    if (f is Exponentiation) {
      base = f.base;
      exponent = f.exponent;
    } else {
      base = f;
      exponent = n(1);
    }

    //for every operand in the denominator, checks if the other is equal to the base or if it is also an exponentiation with the same base.
    for (int j = 0; j < denominatorList.length; ++j) {
      bscFunction g = denominatorList[j];
      if (g is Exponentiation) {
        if (g.base == base) {
          denominatorList.removeAt(j);
          exponent -= g.exponent;
        }
      } else {
        if (g == base) {
          denominatorList.removeAt(j);
          exponent -= n(1);
        }
      }
    }

    numeratorList.removeAt(i);
    if (exponent is Number && exponent.negative) {
      denominatorList.add(base ^ (-exponent));
    } else {
      numeratorList.insert(i, base ^ exponent);
    }
  }
  if (numeratorList.length == 0) numeratorList.add(n(1));
}

///if there are multiplications or divisions, takes their operands and adds them to the lists
void _openMultiplicationsAndDivisions(
    List<bscFunction> numeratorList, List<bscFunction> denominatorList) {
  for (int i = 0; i < numeratorList.length;) {
    bscFunction f = numeratorList[i];
    //if there is a multiplication in numeratorList, takes its operands and adds them to the list
    if (f is Multiplication) {
      numeratorList.removeAt(i);
      numeratorList.insertAll(i, f.operands);
      //if there is a division, adds its numerator to the numeratorList and its denominator to the denominatorlist
    } else if (f is Division) {
      numeratorList.removeAt(i);
      bscFunction numerator = f.numerator;

      if (numerator is Multiplication)
        numeratorList.insertAll(i, numerator.operands);
      else
        numeratorList.insert(i, numerator);

      bscFunction denominator = f.denominator;

      if (denominator is Multiplication)
        denominatorList.addAll(denominator.operands);
      else
        denominatorList.add(denominator);
    } else
      ++i;
  }

  //the same for denominatorList
  for (int i = 0; i < denominatorList.length;) {
    bscFunction f = denominatorList[i];

    if (f is Multiplication) {
      denominatorList.removeAt(i);
      denominatorList.insertAll(i, f.operands);
    } else if (f is Division) {
      denominatorList.removeAt(i);
      bscFunction numerator = f.numerator;

      if (numerator is Multiplication)
        denominatorList.insertAll(i, numerator.operands);
      else
        denominatorList.insert(i, numerator);

      bscFunction denominator = f.denominator;

      if (denominator is Multiplication)
        numeratorList.addAll(denominator.operands);
      else
        numeratorList.add(denominator);
    } else
      ++i;
  }
}

///if operands can be joined as an exponentiation, does it
void _createExponents(List<bscFunction> operands) {
  for (int i = 0; i < operands.length; ++i) {
    //for each operand, divides it into base and exponent, event if the exponent is 1
    bscFunction f = operands[i];

    bscFunction base;
    bscFunction exponent;

    if (f is Exponentiation) {
      base = f.base;
      exponent = f.exponent;
    } else {
      base = f;
      exponent = n(1);
    }

    //for every following operand, checks if the other is equal to the base or if it is also an exponentiation with the same base.
    for (int j = i + 1; j < operands.length; ++j) {
      bscFunction g = operands[j];
      if (g is Exponentiation) {
        if (g.base == base) {
          operands.removeAt(j);
          exponent += g.exponent;
        }
      } else {
        if (g == base) {
          operands.removeAt(j);
          exponent += n(1);
        }
      }
    }

    if (exponent != n(1)) {
      operands.removeAt(i);
      operands.insert(i, base ^ exponent);
    }
  }
}
