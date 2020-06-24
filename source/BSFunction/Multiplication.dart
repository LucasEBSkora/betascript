import 'Division.dart';
import 'Exponentiation.dart';
import 'Negative.dart';
import 'Number.dart';
import 'Sum.dart';
import '../Utils/Tuples.dart';
import 'BSFunction.dart';
import 'Variable.dart';

import '../Utils/xor.dart';

import 'dart:collection' show SplayTreeSet;

BSFunction multiply(List<BSFunction> operands) {
  if (operands == null || operands.length == 0) return (n(0));

  _openOtherMultiplications(operands);

  bool divisionNegatives = false;

  //if there are any divions in the operands, makes a new division with its numerator with
  //the other operands added, and its denominator
  for (int i = 0; i < operands.length; ++i) {
    List<BSFunction> divisions = List();

    for (int i = 0; i < operands.length;) {
      Trio<Division, bool, bool> _op =
          BSFunction.extractFromNegative<Division>(operands[i]);
      if (_op.second) {
        operands.removeAt(i);

        if (_op.third) divisionNegatives = !divisionNegatives;

        divisions.add(_op.first);
      } else
        ++i;
    }

    if (divisions.length != 0) {
      List<BSFunction> nums = List();
      List<BSFunction> dens = List();

      nums.addAll(operands);

      for (Division f in divisions) {
        BSFunction num = f.numerator;
        if (num is Multiplication)
          nums.addAll(num.operands);
        else
          nums.add(num);

        BSFunction den = f.denominator;
        if (den is Multiplication)
          dens.addAll(den.operands);
        else
          dens.add(den);
      }

      return divide(nums, dens);
    }
  }

  bool negativeForNumbers = _multiplyNumbers(operands);
  bool negativeOthers = _consolidateNegatives(operands);

  bool _negative = xor(negativeForNumbers, negativeOthers);
  _negative = xor(_negative, divisionNegatives);

  _createExponents(operands);

  BSFunction _mul;

  if (operands.length == 0)
    return n(0);
  else if (operands.length == 1)
    _mul = operands[0];
  else
    _mul = Multiplication._(operands, null);

  return (_negative) ? negative(_mul) : _mul;
}

class Multiplication extends BSFunction {
  final List<BSFunction> operands;

  Multiplication._(List<BSFunction> this.operands, Set<Variable> params)
      : super(params);

  @override
  BSFunction derivativeInternal(Variable v) {
    List<BSFunction> ops = List<BSFunction>();

    for (int i = 0; i < operands.length; ++i) {
      //copies list
      List<BSFunction> term = [...operands];

      //removes "current" operand (which isn't derivated)
      BSFunction current = term.removeAt(i);

      //Derivates the others
      List<BSFunction> termExpression = term.map((f) {
        return f.derivativeInternal(v);
      }).toList();

      //includes the current element again
      termExpression.insert(i, current);

      //adds to the list of elements to sum
      ops.add(multiply(termExpression));
    }
    return add(ops);
  }

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    List<BSFunction> ops = new List();
    operands.forEach((BSFunction f) {
      ops.add(f.evaluate(p));
    });
    return multiply(ops);
  }

  @override
  String toString([bool handleMinus = true]) {
    String s = '(';

    s += operands[0].toString();

    for (int i = 1; i < operands.length; ++i) {
      s += '*' + operands[i].toString();
    }

    s += ')';

    return s;
  }

  @override
  BSFunction copy([Set<Variable> params = null]) =>
      Multiplication._(operands, params);

  @override
  SplayTreeSet<Variable> get defaultParameters {
    Set<Variable> params = SplayTreeSet();

    for (BSFunction operand in operands) params.addAll(operand.parameters);

    return params;
  }

  @override
  BSFunction get approx {
    List<BSFunction> ops = new List();
    operands.forEach((BSFunction f) {
      ops.add(f.approx);
    });
    return multiply(ops);
  }
}

///If there are other Multiplications in the operand list, takes its operands and adds them to the list
void _openOtherMultiplications(List<BSFunction> operands) {
  int i = 0;
  while (i < operands.length) {
    Trio<Multiplication, bool, bool> _op =
        BSFunction.extractFromNegative<Multiplication>(operands[i]);

    if (_op.second) {
      operands.removeAt(i);
      Multiplication m = _op.first;
      operands.insertAll(i, m.operands);
      if (_op.third) operands.add(n(-1));
    } else
      ++i;
  }
}

///Returns the value of "negative" and takes all numbers be multiplied.
bool _multiplyNumbers(List<BSFunction> operands) {
  double number = 1;
  bool negative = false;

  //used to store named numbers, because they shouldn't be multiplied with the others
  //the key is the name of the number, the double is its value, and the int is the power
  //to which it should be raised
  Map<String, Pair<double, int>> namedNumbers = Map();

  int i = 0;
  while (i < operands.length) {
    //if the operand is a number, removes it and

    Trio<Number, bool, bool> _op =
        BSFunction.extractFromNegative<Number>(operands[i]);

    if (_op.second) {
      operands.removeAt(i);
      Number n = _op.first;
      //if it's a regular number, just multiplies the accumulator
      if (!n.isNamed)
        number *= n.value * (_op.third ? -1 : 1);
      else {
        //if it's named, adds it to the map.

        if (!namedNumbers.containsKey(n.name))
          namedNumbers[n.name] = Pair<double, int>(n.absvalue, 0);

        ++namedNumbers[n.name].second;

        if (_op.third) number *= -1;
      }
    } else
      ++i;
  }

  //if the number is 0, there was a 0 in the List, so the multiplications is 0.
  if (number == 0)
    operands.clear();
  else {
    //makes a new list with the normal number and the named numbers
    List<BSFunction> numbers = List<BSFunction>();
    if (number < 0) negative = true;
    if (number.abs() != 1) numbers.add(n(number.abs()));

    //adds the named numbers
    for (String key in namedNumbers.keys) {
      if (namedNumbers[key].second != 0)
        numbers.add(namedNumber(namedNumbers[key].first, key) ^
            n(namedNumbers[key].second));
    }

    //adds the numbers to the operands
    operands.insertAll(0, numbers);

    //if the multiplication was only numbers and the number left is 1, adds 1 to the operands.
    if (number.abs() == 1 && operands.length == 0) operands.add(n(1));
  }

  return negative;
}

bool _consolidateNegatives(List<BSFunction> operands) {
  bool _negative = false;

  List<BSFunction> newOperands = operands.map((BSFunction f) {
    Trio<BSFunction, bool, bool> _op = BSFunction.extractFromNegative(f);
    if (_op.third) _negative = !_negative;
    return _op.first;
  }).toList();

  operands.clear();
  operands.insertAll(0, newOperands);

  return _negative;
}

///if operands can be joined as an exponentiation, does it
void _createExponents(List<BSFunction> operands) {
  for (int i = 0; i < operands.length; ++i) {
    //for each operand, divides it into base and exponent, event if the exponent is 1
    BSFunction f = operands[i];

    BSFunction base;
    BSFunction exponent;

    if (f is Exponentiation) {
      base = f.base;
      exponent = f.exponent;
    } else {
      base = f;
      exponent = n(1);
    }

    //for every following operand, checks if the other is equal to the base or if it is also an exponentiation with the same base.
    for (int j = i + 1; j < operands.length; ++j) {
      BSFunction g = operands[j];
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
