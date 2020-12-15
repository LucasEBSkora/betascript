import 'dart:collection' show SplayTreeSet;

import 'empty_set.dart';
import 'interval.dart';
import 'set_union.dart';
import 'set.dart';
import '../function/number.dart';
import '../function/function.dart';
import 'visitor/set_visitor.dart';

BSSet rosterSet(Iterable<BSFunction> elements) {
  if (elements.isEmpty) return emptySet;
  print(elements);

  elements = elements.map((e) => e.asConstant());

  print(elements);
  for (var element in elements) {
    if (element == null)
      throw SetDefinitionError("Roster sets can only be defined in constants!");
  }

  return RosterSet(SplayTreeSet.from(elements));
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
  ReturnType accept<ReturnType>(SetVisitor visitor) =>
      visitor.visitRosterSet(this);

  @override
  bool get isIntensional => false;

  @override
  BSSet get knownElements => this;
}
