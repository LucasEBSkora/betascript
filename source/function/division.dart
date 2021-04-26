import 'dart:collection' show HashMap, SplayTreeSet;

import 'exponentiation.dart';
import 'function.dart';
import 'multiplication.dart';
import 'negative.dart';
import 'number.dart';
import 'utils.dart' show extractFromNegative;
import 'variable.dart';
import 'visitors/function_visitor.dart';

BSFunction divide(
    List<BSFunction> numeratorList, List<BSFunction> denominatorList) {
  _openMultiplicationsAndDivisions(numeratorList, denominatorList);
  _createExponents(numeratorList);
  _createExponents(denominatorList);
  _eliminateDuplicates(numeratorList, denominatorList);

  BSFunction numerator = multiply(numeratorList);

  if (denominatorList.isEmpty) return numerator;

  BSFunction denominator = multiply(denominatorList);

  if (numerator == denominator) return n(1);
  if (numerator == n(0)) return n(0);
  if (denominator.asConstant()?.approx == n(0)) {
    if ((numerator is Negative) ^ (denominator is Negative)) {
      return Constants.negativeInfinity;
    } else {
      return Constants.infinity;
    }
  }

  Division div = Division._(
      (numerator is Negative) ? numerator.operand : numerator,
      (denominator is Negative) ? denominator.operand : denominator);

  return ((numerator is Negative) ^ (denominator is Negative)
      ? negative(div)
      : div);
}

class Division extends BSFunction {
  final BSFunction numerator;
  final BSFunction denominator;

  const Division._(this.numerator, this.denominator,
      [Set<Variable> params = const <Variable>{}])
      : super(params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final _n = numerator.evaluate(p);
    final _d = denominator.evaluate(p);

    final _num = extractFromNegative(_n);
    final _den = extractFromNegative(_d);

    if (_num.first is Number && _den.first is Number) {
      final _numNumber = _num.first as Number;
      final _denNumber = _den.first as Number;

      final v = _numNumber.value / _denNumber.value;
      if (v == v.toInt()) return n(v * ((_num.second ^ _den.second) ? -1 : 1));
    }

    return (_num.second ^ _den.second)
        ? negative(divide([_num.first], [_den.first]))
        : divide([_num.first], [_den.first]);
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) =>
      Division._(numerator, denominator, params);

  @override
  SplayTreeSet<Variable> get defaultParameters => SplayTreeSet<Variable>.from(
      <Variable>{...numerator.parameters, ...denominator.parameters});

  @override
  BSFunction get approx {
    final _n = numerator.approx;
    final _d = denominator.approx;

    final _num = extractFromNegative(_n);
    final _den = extractFromNegative(_d);

    if (_num.first is Number && _den.first is Number) {
      final _numNumber = _num.first as Number;
      final _denNumber = _den.first as Number;
      return n(_numNumber.value /
          _denNumber.value *
          ((_num.second ^ _den.second) ? -1 : 1));
    }

    return (_num.second ^ _den.second)
        ? negative(divide([_num.first], [_den.first]))
        : divide([_num.first], [_den.first]);
  }

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitDivision(this);
}

///Cancels out identical factors in [numerator] and [denominator]
///, also opening exponentiations when possible
void _eliminateDuplicates(
    List<BSFunction> numeratorList, List<BSFunction> denominatorList) {
  for (var i = 0; i < numeratorList.length; ++i) {
    //for each operand in the numerator, divides it into base and exponent, event if the exponent is 1
    final f = numeratorList[i];

    BSFunction base;
    BSFunction exponent;

    if (f is Exponentiation) {
      base = f.base;
      exponent = f.exponent;
    } else {
      base = f;
      exponent = n(1);
    }

    //for every operand in the denominator, checks if the other is equal to the base or if it is also an exponentiation with the same base.
    for (int j = 0; j < denominatorList.length; ++j) {
      final g = denominatorList[j];
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
    if (exponent is Negative && (exponent.operand) is Number) {
      denominatorList.add(base ^ (-exponent));
    } else {
      numeratorList.insert(i, base ^ exponent);
    }
  }
  if (numeratorList.isEmpty) numeratorList.add(n(1));
}

///if there are multiplications or divisions, takes their operands and adds them to the lists
void _openMultiplicationsAndDivisions(
    List<BSFunction> numeratorList, List<BSFunction> denominatorList) {
  for (int i = 0; i < numeratorList.length;) {
    final f = numeratorList[i];
    //if there is a multiplication in numeratorList, takes its operands and adds them to the list
    if (f is Multiplication) {
      numeratorList.removeAt(i);
      numeratorList.insertAll(i, f.operands);
      //if there is a division, adds its numerator to the numeratorList and its denominator to the denominatorlist
    } else if (f is Division) {
      numeratorList.removeAt(i);
      BSFunction numerator = f.numerator;

      if (numerator is Multiplication) {
        numeratorList.insertAll(i, numerator.operands);
      } else {
        numeratorList.insert(i, numerator);
      }

      final denominator = f.denominator;

      if (denominator is Multiplication) {
        denominatorList.addAll(denominator.operands);
      } else {
        denominatorList.add(denominator);
      }
    } else {
      ++i;
    }
  }

  //the same for denominatorList
  for (var i = 0; i < denominatorList.length;) {
    final f = denominatorList[i];

    if (f is Multiplication) {
      denominatorList.removeAt(i);
      denominatorList.insertAll(i, f.operands);
    } else if (f is Division) {
      denominatorList.removeAt(i);
      final numerator = f.numerator;

      if (numerator is Multiplication) {
        denominatorList.insertAll(i, numerator.operands);
      } else {
        denominatorList.insert(i, numerator);
      }

      final denominator = f.denominator;

      if (denominator is Multiplication) {
        numeratorList.addAll(denominator.operands);
      } else {
        numeratorList.add(denominator);
      }
    } else {
      ++i;
    }
  }
}

///if operands can be joined as an [Exponentiation], does it
void _createExponents(List<BSFunction> operands) {
  for (var i = 0; i < operands.length; ++i) {
    //for each operand, divides it into base and exponent, event if the exponent is 1
    final f = operands[i];

    var base;
    var exponent;

    if (f is Exponentiation) {
      base = f.base;
      exponent = f.exponent;
    } else {
      base = f;
      exponent = n(1);
    }

    //for every following operand, checks if the other is equal to the base or if it is also an exponentiation with the same base.
    for (int j = i + 1; j < operands.length; ++j) {
      final g = operands[j];
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
