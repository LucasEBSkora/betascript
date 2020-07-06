import 'dart:math';

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
      return RosterSet([a]);
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
  BSSet complement() => DisjoinedSetUnion([
        Interval(-constants.infinity, a, false, !leftClosed),
        Interval(b, constants.infinity, !rightClosed, false)
      ]);

  @override
  bool contains(BSSet x) {
    //if x is an interval, both edges of x need to belong to this set.
    //If the edges are equal, 'this' needs to be closed or x needs to be closed in that edge
    if (x is Interval)
      return (belongs(x.a) || (a == x.a && (leftClosed || !x.leftClosed))) &&
          (belongs(x.b) || (a == x.a && (rightClosed || !x.rightClosed)));
    if (x is DisjoinedSetUnion) //all subsets of x need to be contained in this
      return x.subsets.fold(
          true, (previousValue, element) => previousValue && contains(element));
    if (x is RosterSet) //all elements of x need to be belong to this
      return x.elements.fold(
          true, (previousValue, element) => previousValue && belongs(element));

    //only case it gets to this point is empty set.
    return true;
  }

  @override
  BSSet intersection(BSSet x) {
    //We first check if the elements are disjoined
    if (disjoined(x)) return emptySet;
    if (x is Interval) {
      BSFunction _a = BSFunction.max(this.a, x.a);
      BSFunction _b = BSFunction.min(this.b, x.b);

      bool _leftClosed;
      if (this.a == x.a)
        _leftClosed = this.leftClosed && x.leftClosed;
      else
        _leftClosed = this.a > x.a ? this.leftClosed : x.leftClosed;

      bool _rightClosed;
      if (this.b == x.b)
        _rightClosed = this.rightClosed && x.rightClosed;
      else
        _rightClosed = this.b < x.b ? this.rightClosed : x.rightClosed;

      return interval(_a, _b,
          leftClosed: _leftClosed, rightClosed: _rightClosed);
    }
    
    if (x is DisjoinedSetUnion) {
      //Depends on the simplifications to remove empty sets that remain
      return disjoinedSetUnion(x.subsets.map((e) => intersection(e)));
    }
    if (x is RosterSet) {
      //creates a new disjoinedSetUnion with the two, but removes the elements of x contained in the interval
      //To keep the sets disjoined
      return DisjoinedSetUnion(
          [this, RosterSet(x.elements.where((element) => !belongs(element)))]);
    }

    //only case it would get to this point is empty set.
    return emptySet;
  }

  @override
  BSSet relativeComplement(BSSet x) {
    if (disjoined(x)) return this;
  }

  @override
  BSSet union(BSSet x) {
    if (disjoined(x)) return DisjoinedSetUnion([this, x]);
    if (x is Interval) {
      BSFunction _a = BSFunction.min(this.a, x.a);
      BSFunction _b = BSFunction.max(this.b, x.b);

      bool _leftClosed;
      if (this.a == x.a)
        _leftClosed = this.leftClosed || x.leftClosed;
      else
        _leftClosed = this.a < x.a ? this.leftClosed : x.leftClosed;

      bool _rightClosed;
      if (this.b == x.b)
        _rightClosed = this.rightClosed || x.rightClosed;
      else
        _rightClosed = this.b > x.b ? this.rightClosed : x.rightClosed;

      return interval(_a, _b,
          leftClosed: _leftClosed, rightClosed: _rightClosed);
    }
    if (x is DisjoinedSetUnion) {
      Set<BSSet> _new = Set.from(x.subsets);
      _new.add(this);
      return DisjoinedSetUnion(_new);
    }
    if (x is RosterSet) {
      //creates a new disjoinedSetUnion with the two, but removes the elements of x contained in the interval
      //To keep the sets disjoined
      return DisjoinedSetUnion(
          [this, RosterSet(x.elements.where((element) => !belongs(element)))]);
    }

    //only case it would get to this point is empty set.
    return this;
  }

  @override
  bool disjoined(BSSet b) {
    if (b is Interval)
      //one of the intervals has to have all its elements before the other one
      return (this.b < b.a) ||
          (b.b < this.b) ||
          //or the two share an edge, but one of them doesn't include it
          (this.b == b.a && (!this.rightClosed || !b.leftClosed)) ||
          (this.a == b.b && (!this.leftClosed || !b.rightClosed));
    if (b is DisjoinedSetUnion)
      //this must be disjoined with all subsets of b
      return b.subsets.fold(true,
          (previousValue, element) => previousValue && disjoined(element));
    if (b is RosterSet)
      //no element of b belongs to this
      return b.elements.fold(
          true, (previousValue, element) => previousValue && !belongs(element));

    //only case it gets to this point is empty set.
    return true;
  }

  @override
  String toString() =>
      "${(leftClosed) ? '[' : '('}$a,$b${(rightClosed) ? ']' : ')'}";
}
