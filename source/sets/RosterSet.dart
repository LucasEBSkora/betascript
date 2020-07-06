import 'dart:collection' show SplayTreeSet;

import '../BSFunction/BSFunction.dart';
import '../BSFunction/Number.dart';
import 'BSSet.dart';
import 'DisjoinedSetUnion.dart';
import 'EmptySet.dart';

//a class that represents an interval in R
class RosterSet extends BSSet {
  final SplayTreeSet<BSFunction> elements;

  RosterSet(Iterable<BSFunction> elements) : elements = elements ;

  @override
  bool belongs(BSFunction x)

  @override
  BSSet complement() => 

  @override
  bool contains(BSSet x) {
    //if x is a set, both edges of x need to belong to this set.
    //If the edges are equal, 'this' needs to be closed or x needs to be closed in that edge
    if (x is EmptySet)
      return true;
    else if (x is Interval)
      return (belongs(x.a) || (a == x.a && (leftClosed || !x.leftClosed))) &&
          (belongs(x.b) || (a == x.a && (rightClosed || !x.rightClosed)));
    else if (x
        is DisjoinedSetUnion) //all subsets of x need to be contained in this
      return x.subsets.fold(
          true, (previousValue, element) => previousValue && contains(element));
    else if (x is RosterSet) //all elements of x need to be belong to this
      return x.elements.fold(
          true, (previousValue, element) => previousValue && belongs(element));
  }

  @override
  BSSet intersection(BSSet x) {
    if (disjoined(x)) return DisjoinedSetUnion([this, x]);
    if (x is Interval) {}
  }

  @override
  BSSet relativeComplement(BSSet x) {}

  @override
  BSSet union(BSSet x) {}

  @override
  bool disjoined(BSSet b) {}

  @override
  String toString() =>
      "${(leftClosed) ? '[' : '('}$a,$b${(rightClosed) ? ']' : ')'}";
}
