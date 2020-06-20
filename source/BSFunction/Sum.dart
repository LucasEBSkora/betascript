import 'Multiplication.dart';
import 'Number.dart';
import 'Variable.dart';
import 'BSFunction.dart';

import '../Utils/Pair.dart';
import 'dart:collection' show SplayTreeSet;
BSFunction add(List<BSFunction> operands) {
  if (operands == null || operands.length == 0) return n(0);

  bool negative = false;

  _openOtherSums(operands);
  _SumNumbers(operands);

  _createMultiplications(operands);

  if (operands.length == 0)
    return n(0);
  else if (operands.length == 1)
    return operands[0];
  else
    return Sum._(operands, negative, null);
}

class Sum extends BSFunction {
  final List<BSFunction> operands;

  Sum._(List<BSFunction> this.operands, bool negative, Set<Variable> params)
      : super(negative, params);

  @override
  BSFunction derivative(Variable v) {
    return add(operands.map((BSFunction f) {
      return f.derivative(v);
    }).toList())
        .invertSign(negative);
  }

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    
    List<BSFunction> ops = new List();
    operands.forEach((BSFunction f) {
      ops.add(f.evaluate(p));
    });
    return add(ops).copy(negative);
  }

  @override
  String toString([bool handleMinus = true]) {
    String s = minusSign(handleMinus);
    s += '(';

    s += operands[0].toString(true);

    for (int i = 1; i < operands.length; ++i) {
      s += ((operands[i].negative) ? " - " : " + ") +
          operands[i].toString(false);
    }

    s += ')';

    return s;
  }

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => Sum._(operands, negative, params);

  @override
  SplayTreeSet<Variable> get minParameters {
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
    return add(ops).copy(negative);
  }
}

///If the List passed already has Sums in it, removes the Sum and adds its operators to the list
void _openOtherSums(List<BSFunction> operands) {
  int i = 0;
  while (i < operands.length) {
    if (operands[i] is Sum) {
      Sum s = operands.removeAt(i);

      List<BSFunction> newOperands = List<BSFunction>();

      if (s.negative) {
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

  Map<String, Pair<double, int>> namedNumbers =
      Map<String, Pair<double, int>>();

  int i = 0;
  while (i < operands.length) {
    if (operands[i] is Number) {
      Number n = operands.removeAt(i);
      if (!n.isNamed)
        number += n.value;
      else {
        if (!namedNumbers.containsKey(n.name))
          namedNumbers[n.name] = Pair<double, int>(n.value, 0);

        namedNumbers[n.name].second += (n.negative ? -1 : 1);
      }
    } else
      ++i;
  }

  List<BSFunction> numbers = List<BSFunction>();

  if (number > 0)
    numbers.add(n(number));
  else if (number < 0) operands.add(n(number));

  for (String key in namedNumbers.keys) {
    if (namedNumbers[key].second != 0)
      numbers.add(n(namedNumbers[key].second) *
          namedNumber(namedNumbers[key].first, key));
  }

  operands.insertAll(0, numbers);
}

//Sums up equal functions so that things like x + x become 2*x
void _createMultiplications(List<BSFunction> operands) {
  for (int i = 0; i < operands.length; ++i) {
    //for each operand, divides it into numeric factor and function
    BSFunction f = operands[i];

    BSFunction h;
    BSFunction factor;

    if (f is Multiplication &&
        f.operands.length == 2 &&
        f.operands[0] is Number) {
      h = f.operands[1];
      factor = f.operands[0];
    } else {
      h = f;
      factor = n(1);
    }

    for (int j = i + 1; j < operands.length; ++j) {
      BSFunction g = operands[j];

      if (g is Multiplication &&
          g.operands.length == 2 &&
          g.operands[0] is Number) {
        if (h == g.operands[1]) {
          operands.removeAt(j);
          factor += g.operands[0];
        }
      } else {
        if (g == h) {
          operands.removeAt(j);
          factor += n(1);
        }
      }
    }

    if (factor != n(1)) {
      operands.removeAt(i);
      operands.insert(i, factor * h);
    }
  }
}
