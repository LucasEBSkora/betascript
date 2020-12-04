import 'dart:collection' show HashMap, SplayTreeSet;

import 'division.dart';
import 'exponentiation.dart';
import 'function.dart';
import 'visitors/function_visitor.dart';
import 'negative.dart';
import 'number.dart';
import 'variable.dart';
import '../utils/tuples.dart';

BSFunction multiply(List<BSFunction> operands) {
  if (operands?.isEmpty ?? true) return (n(0));

  _openOtherMultiplications(operands);

  var divisionNegatives = false;

  //if there are any divions in the operands, makes a new division with its numerator with
  //the other operands added, and its denominator
  for (var i = 0; i < operands.length; ++i) {
    final divisions = <Division>[];

    for (var i = 0; i < operands.length;) {
      final _op = BSFunction.extractFromNegative<Division>(operands[i]);
      if (_op.second) {
        operands.removeAt(i);

        if (_op.third) divisionNegatives = !divisionNegatives;

        divisions.add(_op.first);
      } else
        ++i;
    }

    if (divisions.isNotEmpty) {
      final nums = <BSFunction>[...operands];
      final dens = <BSFunction>[];

      for (Division f in divisions) {
        final numerator = f.numerator;
        if (numerator is Multiplication) {
          nums.addAll(numerator.operands);
        } else {
          nums.add(numerator);
        }

        final denominator = f.denominator;
        if (denominator is Multiplication) {
          dens.addAll(denominator.operands);
        } else {
          dens.add(denominator);
        }
      }

      return divide(nums, dens);
    }
  }

  final negativeForNumbers = _multiplyNumbers(operands);
  final negativeOthers = _consolidateNegatives(operands);

  var _negative = negativeForNumbers ^ negativeOthers;
  _negative = _negative ^ divisionNegatives;

  _createExponents(operands);

  BSFunction _mul;

  if (operands.isEmpty) {
    return n(0);
  } else if (operands.length == 1) {
    _mul = operands[0];
  } else {
    _mul = Multiplication(operands);
  }

  return (_negative) ? negative(_mul) : _mul;
}

class Multiplication extends BSFunction {
  final List<BSFunction> operands;

  const Multiplication(this.operands, [Set<Variable> params]) : super(params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) =>
      multiply(<BSFunction>[for (final f in operands) f.evaluate(p)]);

  @override
  BSFunction copy([Set<Variable> params]) => Multiplication(operands, params);

  @override
  SplayTreeSet<Variable> get defaultParameters => SplayTreeSet<Variable>.from(
      <Variable>{for (final operand in operands) ...operand.parameters});

  @override
  BSFunction get approx =>
      multiply(<BSFunction>[for (var f in operands) f.approx]);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitMultiplication(this);
}

///If there are other [Multiplication]s in [operands],
///takes its operands and adds them to the list
void _openOtherMultiplications(List<BSFunction> operands) {
  var i = 0;
  while (i < operands.length) {
    final _op = BSFunction.extractFromNegative<Multiplication>(operands[i]);

    if (_op.second) {
      operands.removeAt(i);
      var m = _op.first;
      operands.insertAll(i, m.operands);
      if (_op.third) operands.add(n(-1));
    } else
      ++i;
  }
}

///Returns the value of "negative" and makes all [Number]s be multiplied.
bool _multiplyNumbers(List<BSFunction> operands) {
  var number = 1.0;
  var negative = false;

  //used to store named numbers, because they shouldn't be multiplied with the others
  //the key is the name of the number, the double is its value, and the int is the power
  //to which it should be raised
  final namedNumbers = HashMap<String, Pair<double, int>>();

  var i = 0;
  while (i < operands.length) {
    //if the operand is a number, removes it and

    final _op = BSFunction.extractFromNegative<Number>(operands[i]);

    if (_op.second) {
      operands.removeAt(i);
      final n = _op.first;
      //if it's a regular number, just multiplies the accumulator
      if (!n.isNamed) {
        number *= n.value * (_op.third ? -1 : 1);
      } else {
        //if it's named, adds it to the map.

        if (!namedNumbers.containsKey(n.name)) {
          namedNumbers[n.name] = Pair<double, int>(n.absvalue, 0);
        }

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
    final numbers = <BSFunction>[];
    if (number < 0) negative = true;
    if (number.abs() != 1) numbers.add(n(number.abs()));

    //adds the named numbers
    for (final key in namedNumbers.keys) {
      if (namedNumbers[key].second != 0) {
        numbers.add(namedNumber(namedNumbers[key].first, key) ^
            n(namedNumbers[key].second));
      }
    }

    //adds the numbers to the operands
    operands.insertAll(0, numbers);

    //if the multiplication was only numbers and the number left is 1, adds 1 to the operands.
    if (number.abs() == 1 && operands.isEmpty) operands.add(n(1));
  }

  return negative;
}

bool _consolidateNegatives(List<BSFunction> operands) {
  var _negative = false;

  final newOperands = operands.map((BSFunction f) {
    final _op = BSFunction.extractFromNegative(f);
    if (_op.third) _negative = !_negative;
    return _op.first;
  }).toList();

  operands.clear();
  operands.insertAll(0, newOperands);

  return _negative;
}

///if operands can be joined as an [Exponentiation], does it
void _createExponents(List<BSFunction> operands) {
  for (var i = 0; i < operands.length; ++i) {
    //for each operand, divides it into base and exponent, event if the exponent is 1
    final f = operands[i];

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
    for (var j = i + 1; j < operands.length; ++j) {
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
