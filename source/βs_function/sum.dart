import 'dart:collection' show HashMap, SplayTreeSet;

import 'multiplication.dart';
import 'negative.dart';
import 'number.dart';
import 'variable.dart';
import 'βs_function.dart';
import '../utils/tuples.dart';

BSFunction add(List<BSFunction> operands) {
  if (operands == null || operands.length == 0) return n(0);

  _openOtherSums(operands);
  _SumNumbers(operands);
  _createMultiplications(operands);
  if (operands.length == 0) {
    return n(0);
  } else if (operands.length == 1) {
    return operands[0];
  } else {
    return Sum._(operands, null);
  }
}

class Sum extends BSFunction {
  final List<BSFunction> operands;

  Sum._(List<BSFunction> this.operands, Set<Variable> params) : super(params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      add(operands.map((BSFunction f) => f.derivativeInternal(v)).toList());

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) =>
      add(operands.map((BSFunction f) => f.evaluate(p)).toList());

  @override
  String toString([bool handleMinus = true]) {
    String s = '(';

    s += operands[0].toString();

    for (int i = 1; i < operands.length; ++i) {
      BSFunction _op = operands[i];
      if (_op is Negative) {
        s += " - ";
        _op = (_op as Negative).operand;
      } else
        s += " + ";

      s += _op.toString();
    }

    s += ')';

    return s;
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => Sum._(operands, params);

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
    return add(ops);
  }
}

///If the List passed already has Sums in it, removes the Sum and adds its operators to the list
void _openOtherSums(List<BSFunction> operands) {
  int i = 0;
  while (i < operands.length) {
    Trio<Sum, bool, bool> _op =
        BSFunction.extractFromNegative<Sum>(operands[i]);

    //if it finds a sum
    if (_op.second) {
      Sum s = operands.removeAt(i);

      List<BSFunction> newOperands = List<BSFunction>();

      //if it finds a sum within a negative
      if (_op.third) {
        s.operands.forEach((BSFunction f) {
          newOperands.add(-f);
        });
      } else
        newOperands = s.operands;

      operands.insertAll(i, newOperands);
    } else
      ++i;
  }
}

///Gets the operands, sums up all numbers and adds them to the beginning of the list (which already eliminates zeros)
void _SumNumbers(List<BSFunction> operands) {
  double number = 0;

  HashMap<String, Pair<double, int>> namedNumbers =
      HashMap<String, Pair<double, int>>();

  int i = 0;
  while (i < operands.length) {
    bool _negative = operands[i] is Negative;
    BSFunction op =
        ((_negative) ? (operands[i] as Negative).operand : operands[i]);

    if (op is Number) {
      operands.removeAt(i);
      Number n = op;
      if (!n.isNamed) {
        number += n.value * (_negative ? -1 : 1);
      } else {
        if (!namedNumbers.containsKey(n.name)) {
          namedNumbers[n.name] = Pair<double, int>(n.value, 0);
        }

        namedNumbers[n.name].second += (_negative ? -1 : 1);
      }
    } else
      ++i;
  }

  List<BSFunction> numbers = List<BSFunction>();

  if (number > 0) {
    numbers.add(n(number));
  } else if (number < 0) operands.add(n(number));

  for (String key in namedNumbers.keys) {
    if (namedNumbers[key].second != 0) {
      numbers.add(n(namedNumbers[key].second) *
          namedNumber(namedNumbers[key].first, key));
    }
  }

  operands.insertAll(0, numbers);
}

//Sums up equal functions so that things like x + x become 2*x
void _createMultiplications(List<BSFunction> operands) {
  //doing everything below without having enough operands to actually do anything is dumb
  if (operands.length < 2) return;
  for (int i = 0; i < operands.length; ++i) {
    //for each operand, divides it into numeric factor and function
    BSFunction f = operands[i];

    BSFunction h;
    BSFunction originalFactor;
    BSFunction factor;
    Trio<Multiplication, bool, bool> _mul =
        BSFunction.extractFromNegative<Multiplication>(f);

    if (_mul.second &&
        _mul.first.operands.length >= 2 &&
        _mul.first.operands[0] is Number) {
      //in this case, "h" must be the multiplication with all other factors excluding the number
      List<BSFunction> otherOps = List.from(_mul.first.operands);
      otherOps.removeAt(0);
      h = Multiplication(otherOps);
      factor = originalFactor = _mul.first.operands[0] * n(_mul.third ? -1 : 1);
    } else {
      Trio<BSFunction, bool, bool> _f = BSFunction.extractFromNegative(f);
      h = _f.first;
      factor = originalFactor = n((_f.third ? -1 : 1));
    }

    for (int j = i + 1; j < operands.length; ++j) {
      BSFunction g = operands[j];
      Trio<Multiplication, bool, bool> _mul =
          BSFunction.extractFromNegative<Multiplication>(g);

      if (_mul.second &&
          _mul.first.operands.length >= 2 &&
          _mul.first.operands[0] is Number) {
        //in this case, "h" must be the multiplication with all other factors excluding the number
        List<BSFunction> otherOps = List.from(_mul.first.operands);
        otherOps.removeAt(0);
        g = Multiplication(otherOps);
        if (h == g) {
          operands.removeAt(j);
          factor += _mul.first.operands[0] * n(_mul.third ? -1 : 1);
        }
      } else {
        Trio<BSFunction, bool, bool> _g = BSFunction.extractFromNegative(g);
        if (_g.first == h) {
          operands.removeAt(j);
          factor += n((_g.third ? -1 : 1));
        }
      }
    }

    if (factor != originalFactor) {
      operands.removeAt(i);
      operands.insert(i, factor * h);
    }
  }
}
