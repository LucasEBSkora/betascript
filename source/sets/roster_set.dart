import 'dart:collection' show SplayTreeSet;

import 'empty_set.dart';
import 'interval.dart';
import 'set_union.dart';
import 'βs_set.dart';
import '../βs_function/number.dart';
import '../βs_function/βs_function.dart';

BSSet rosterSet(Iterable<BSFunction> elements) {
  if (elements.firstWhere(
          (element) => !BSFunction.extractFromNegative<Number>(element).second,
          orElse: () => null) !=
      null) {
    throw SetDefinitionError("Sets can only be defined in real numbers!");
  }

  if (elements.isEmpty) return emptySet;
  return RosterSet(
      SplayTreeSet.from(elements, (BSFunction first, BSFunction second) {
    final _nums = BSFunction.toNums(first, second, "compare");
    return _nums.first.compareTo(_nums.second);
  }));
}

//a class that represents a set created by enumerating its (numeric) elemments
class RosterSet extends BSSet {
  final SplayTreeSet<BSFunction> elements;

  const RosterSet(this.elements);

  @override
  bool belongs(BSFunction x) => elements.contains(x);

  @override
  BSSet complement() {
    //For a set {x1, x2, x3, ..., xn}, its complement is
    //(-∞, x1) U (x1, x2) U (x2, x3) U (x3, x4) ... U (x(n -1), xn) U (xn, +∞)
    return SetUnion(<BSSet>[
      Interval.open(Constants.negativeInfinity, elements.first), //(-∞, x1)
      //(x1, x2) U (x2, x3) U (x3, x4) ... U (x(n -1), xn)
      for (var i = 1; i < elements.length; ++i)
        Interval.open(elements.elementAt(i - 1), elements.elementAt(i)),
      Interval.open(elements.last, Constants.infinity) //(xn, +∞)
    ]);
  }

  @override
  String toString() {
    var s = "{ ";

    s += elements.first.toString();
    for (var i = 1; i < elements.length; ++i) s += ", ${elements.elementAt(i)}";

    s += " }";
    return s;
  }
}
