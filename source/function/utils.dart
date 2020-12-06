import 'function.dart';
import '../utils/tuples.dart';
import 'negative.dart';

///if both values are transformable to numbers (functions without parameters),
///returns them in a pair as numbers. If either doesn't, throws an error, if the name of the operation
///is passed, or returns null otherwise.
Pair<num, num> toNums(BSFunction a, BSFunction b, [String op]) {
  final _a = a.toNum();
  final _b = b.toNum();
  if (_a == null || _b == null) {
    if (op != null) {
      throw BetascriptFunctionError("operand $op can only be used on numbers");
    } else {
      return null;
    }
  }

  return Pair<num, num>(_a, _b);
}

BSFunction min(BSFunction x, BSFunction y) {
  final v = toNums(x, y, "min");
  return (v.first < v.second) ? x : y;
}

BSFunction max(BSFunction x, BSFunction y) {
  final v = toNums(x, y, "max");
  return (v.first > v.second) ? x : y;
}

///Checks if the function f is of Type 'type', or if it is of type Negative and its operand of type 'type'.
///if it manages to find something of the 'type', first is set to it. If it doesn't, it is set to null
///If it is contained inside a negative, second is set to true.
Pair<T, bool> extractFromNegative<T extends BSFunction>(BSFunction f) {
  var _isInNegative = false;
  if (f is Negative) {
    f = (f as Negative).operand;
    _isInNegative = true;
  }

  return Pair((f is T) ? f : null, _isInNegative);
}
