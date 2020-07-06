import '../BSFunction/BSFunction.dart';
import '../BSFunction/Number.dart';
import 'BSSet.dart';
import 'DisjoinedSetUnion.dart';
import 'EmptySet.dart';
import 'RosterSet.dart';
import 'sets.dart';

BSSet interval(BSFunction a, BSFunction b,
    {bool leftClosed = true, bool rightClosed = true}) {
  if (!BSFunction.extractFromNegative<Number>(a).second ||
      !BSFunction.extractFromNegative<Number>(b).second)
    throw BetascriptFunctionError("sets can only be defined in numbers");
  if (a == b) {
    if (leftClosed && rightClosed)
      return rosterSet([a]);
    else
      return emptySet;
  } else if (a > b)
    return emptySet;
  else
    return Interval(a, b, leftClosed, rightClosed);
}

//a class that represents an interval in R
class Interval extends BSSet {
  final bool leftClosed;
  final bool rightClosed;
  final BSFunction a;
  final BSFunction b;

  const Interval(BSFunction this.a, BSFunction this.b, bool this.leftClosed,
      bool this.rightClosed);

  //doesn't need to check if x is number because < will do it anyway
  @override
  bool belongs(BSFunction x) =>
      (a < x && x < b) || (a == x && leftClosed) || (x == b && rightClosed);

  @override
  BSSet complement() => disjoinedSetUnion([
        Interval(-constants.infinity, a, false, !leftClosed),
        Interval(b, constants.infinity, !rightClosed, false)
      ]);


  @override
  String toString() =>
      "${(leftClosed) ? '[' : '('}$a,$b${(rightClosed) ? ']' : ')'}";
}
