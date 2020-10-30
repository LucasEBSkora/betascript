import 'dart:collection' show SplayTreeSet;

import '../BSFunction/BSFunction.dart';
import '../BSFunction/Number.dart';

import 'BSSet.dart';
import 'EmptySet.dart';
import 'SetUnion.dart';
import 'Interval.dart';

import '../Utils/Tuples.dart';

BSSet rosterSet(Iterable<BSFunction> elements) {
  if (elements.firstWhere(
          (element) => !BSFunction.extractFromNegative<Number>(element).second,
          orElse: () => null) !=
      null)
    throw SetDefinitionError("Sets can only be defined in real numbers!");

  if (elements.length == 0) return emptySet;
  return RosterSet(
      SplayTreeSet.from(elements, (BSFunction first, BSFunction second) {
    Pair<num, num> _nums = BSFunction.toNums(first, second, "compare");
    return _nums.first.compareTo(_nums.second);
  }));
}

//a class that represents a set created by enumerating its (numeric) elemments
class RosterSet extends BSSet {
  final SplayTreeSet<BSFunction> elements;

  RosterSet(SplayTreeSet<BSFunction> this.elements);

  @override
  bool belongs(BSFunction x) => elements.contains(x);

  @override
  BSSet complement() {
    List<BSSet> complementSubsets = List();

    //For a set {x1, x2, x3, ..., xn}, its complement is
    //(-∞, x1) U (x1, x2) U (x2, x3) U (x3, x4) ... U (x(n -1), xn) U (xn, +∞)
    complementSubsets
        .add(Interval.open(constants.negativeInfinity, elements.first));

    for (int i = 1; i < elements.length; ++i)
      complementSubsets
          .add(Interval.open(elements.elementAt(i - 1), elements.elementAt(i)));

    complementSubsets.add(Interval.open(elements.last, constants.infinity));

    return SetUnion(complementSubsets);
  }

  @override
  String toString() {
    String s = "{ ";

    s += elements.first.toString();
    for (int i = 1; i < elements.length; ++i) s += ", ${elements.elementAt(i)}";

    s += " }";
    return s;
  }
}
