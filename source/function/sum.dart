import 'dart:collection' show HashMap, SplayTreeSet;

import 'function.dart';
import 'multiplication.dart';
import 'negative.dart';
import 'number.dart';
import 'utils.dart' show extractFromNegative;
import 'variable.dart';
import 'visitors/function_visitor.dart';
import '../utils/tuples.dart';

BSFunction add(List<BSFunction> operands) {
  if (operands.isEmpty) return n(0);

  _openOtherSums(operands);
  _SumNumbers(operands);
  _createMultiplications(operands);
  if (operands.isEmpty) {
    return n(0);
  } else if (operands.length == 1) {
    return operands[0];
  } else {
    return Sum._(operands);
  }
}

class Sum extends BSFunction {
  final List<BSFunction> operands;

  const Sum._(this.operands, [Set<Variable> params = const <Variable>{}])
      : super(params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) =>
      add(operands.map((BSFunction f) => f.evaluate(p)).toList());

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) =>
      Sum._(operands, params);

  @override
  SplayTreeSet<Variable> get defaultParameters => SplayTreeSet<Variable>.from(
      <Variable>{for (final operand in operands) ...operand.parameters});

  @override
  BSFunction get approx =>
      add(<BSFunction>[for (final f in operands) f.approx]);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitSum(this);
}

///If the List passed already has [Sum]s in it, removes the [Sum] and adds its
/// operators to the list
void _openOtherSums(List<BSFunction> operands) {
  var i = 0;
  while (i < operands.length) {
    final _op = extractFromNegative(operands[i]);

    //if it finds a sum
    if (_op.first is Sum) {
      operands.removeAt(i);

      final s = _op.first as Sum;

      var newOperands = <BSFunction>[];

      //if it finds a sum within a negative
      if (_op.second) {
        for (var f in s.operands) {
          newOperands.add(-f);
        }
      } else
        newOperands = s.operands;

      operands.insertAll(i, newOperands);
    } else
      ++i;
  }
}

///Gets the operands, sums up all [Number]s and adds them to the beginning of the
///list (which already eliminates zeros)
void _SumNumbers(List<BSFunction> operands) {
  var number = 0.0;

  final namedNumbers = HashMap<String, Pair<num, num>>();

  var i = 0;
  while (i < operands.length) {
    final _negative = operands[i] is Negative;
    final op = ((_negative) ? (operands[i] as Negative).operand : operands[i]);

    if (op is Number) {
      operands.removeAt(i);
      final n = op;
      if (!n.isNamed) {
        number += n.value * (_negative ? -1 : 1);
      } else {
        if (!namedNumbers.containsKey(n.name)) {
          namedNumbers[n.name] = Pair<num, num>(n.value, 0);
        }

        namedNumbers[n.name]?.second += (_negative ? -1 : 1);
      }
    } else
      ++i;
  }

  final numbers = <BSFunction>[];

  if (number > 0) {
    numbers.add(n(number));
  } else if (number < 0) operands.add(n(number));

  for (final key in namedNumbers.keys) {
    final pair = namedNumbers[key]!;
    if (pair.second != 0) {
      numbers.add(n(pair.second) * namedNumber(pair.first, key));
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
    final f = operands[i];

    BSFunction h;
    BSFunction originalFactor;
    BSFunction factor;
    final _mul = extractFromNegative(f);

    if (_mul.first is Multiplication &&
        (_mul.first as Multiplication).operands.length >= 2 &&
        (_mul.first as Multiplication).operands[0] is Number) {
      //in this case, "h" must be the multiplication with all other factors excluding the number
      final otherOps = (_mul.first as Multiplication).operands.toList();
      otherOps.removeAt(0);
      h = Multiplication(otherOps);
      factor =
          originalFactor = (_mul.first as Multiplication).operands[0] * n(_mul.second ? -1 : 1);
    } else {
      final _f = extractFromNegative(f);
      h = _f.first;
      factor = originalFactor = n((_f.second ? -1 : 1));
    }

    for (var j = i + 1; j < operands.length; ++j) {
      var g = operands[j];
      final _mul = extractFromNegative(g);

      if (_mul.first is Multiplication &&
          (_mul.first as Multiplication).operands.length >= 2 &&
          (_mul.first as Multiplication).operands[0] is Number) {
        //in this case, "h" must be the multiplication with all other factors excluding the number
        final otherOps = (_mul.first as Multiplication).operands.toList();
        otherOps.removeAt(0);
        g = Multiplication(otherOps);
        if (h == g) {
          operands.removeAt(j);
          factor += (_mul.first as Multiplication).operands[0] * n(_mul.second ? -1 : 1);
        }
      } else {
        final _g = extractFromNegative(g);
        if (_g.first == h) {
          operands.removeAt(j);
          factor += n((_g.second ? -1 : 1));
        }
      }
    }

    if (factor != originalFactor) {
      operands.removeAt(i);
      operands.insert(i, factor * h);
    }
  }
}
