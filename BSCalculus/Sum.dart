import 'Multiplication.dart';
import 'Number.dart';
import 'Variable.dart';
import 'bscFunction.dart';

import 'Utils/Pair.dart';

class Sum extends bscFunction {
  final List<bscFunction> operands;

  Sum._(List<bscFunction> this.operands, [bool negative = false])
      : super(negative);

  static bscFunction create(List<bscFunction> operands) {
    if (operands == null || operands.length == 0) return Number(0);

    bool negative = false;

    _openOtherSums(operands);
    _SumNumbers(operands);

    _createMultiplications(operands);

    if (operands.length == 0)
      return Number(0);
    else if (operands.length == 1)
      return operands[0];
    else
      return Sum._(operands, negative);
  }

  ///If the List passed already has Sums in it, removes the Sum and adds its operators to the list
  static void _openOtherSums(List<bscFunction> operands) {
    int i = 0;
    while (i < operands.length) {
      if (operands[i] is Sum) {
        Sum s = operands.removeAt(i);

        List<bscFunction> newOperands = List<bscFunction>();

        if (s.negative) {
          s.operands.forEach((bscFunction f) {
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
  static void _SumNumbers(List<bscFunction> operands) {
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

    List<bscFunction> numbers = List<bscFunction>();

    if (number > 0)
      numbers.add(Number(number));
    else if (number < 0) operands.add(Number(number));

    for (String key in namedNumbers.keys) {
      if (namedNumbers[key].second != 0)
        numbers.add(Number(namedNumbers[key].second) *
            Number.named(namedNumbers[key].first, key));
    }

    operands.insertAll(0, numbers);
  }

  //Sums up equal functions so that things like x + x become 2*x
  static void _createMultiplications(List<bscFunction> operands) {
    for (int i = 0; i < operands.length; ++i) {
      //for each operand, divides it into numeric factor and function
      bscFunction f = operands[i];

      bscFunction h;
      bscFunction factor;

      if (f is Multiplication &&
          f.operands.length == 2 &&
          f.operands[0] is Number) {
        h = f.operands[1];
        factor = f.operands[0];
      } else {
        h = f;
        factor = Number(1);
      }

      //for every following operand, checks if the other is equal to the base or if it is also an exponentiation with the same base.
      for (int j = i + 1; j < operands.length; ++j) {
        bscFunction g = operands[j];

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
            factor += Number(1);
          }
        }
      }

      if (factor != Number(1)) {
        operands.removeAt(i);
        operands.insert(i, factor * h);
      }
    }
  }

  @override
  bscFunction derivative(Variable v) {
    return Sum.create(operands.map((bscFunction f) {
      return f.derivative(v);
    }).toList()).invertSign(negative);
  }

  @override
  num call(Map<String, double> p) {
    num value = 0;
    operands.forEach((bscFunction f) {
      value += f(p);
    });
    return value;
  }

  @override
  String toString([bool handleMinus = true]) {
    String s = '';
    if (negative && handleMinus) s += '-';

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
  bscFunction withSign(bool negative) => Sum._(operands, negative);
}
