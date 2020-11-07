import '../βs_function/βs_function.dart';
import '../βs_function/number.dart';
import 'βs_set.dart';
import 'set_union.dart';
import 'empty_set.dart';
import 'roster_set.dart';

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
    
  const Interval.closed(BSFunction this.a, BSFunction this.b,) : this.leftClosed = true, this.rightClosed = true;
  const Interval.open(BSFunction this.a, BSFunction this.b,) : this.leftClosed = false, this.rightClosed = false;

  //doesn't need to check if x is number because < will do it anyway
  @override
  bool belongs(BSFunction x) =>
      (a < x && x < b) || (a == x && leftClosed) || (x == b && rightClosed);

  @override
  BSSet complement() => SetUnion([
        Interval(-constants.infinity, a, false, !leftClosed),
        Interval(b, constants.infinity, !rightClosed, false)
      ]);


  @override
  String toString() =>
      "${(leftClosed) ? '[' : '('}$a,$b${(rightClosed) ? ']' : ')'}";
}
