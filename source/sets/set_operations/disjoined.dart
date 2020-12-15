import 'dart:collection' show SplayTreeSet;

import 'set_operation.dart';
import '../sets.dart';
import '../../function/function.dart';
import '../../utils/three_valued_logic.dart';

class Disjoined extends EmptyFilteringComutativeSetOperation<BSLogical> {
  BSLogical _disjoinedPositivesAsUnknown(BSSet first, BSSet second) =>
      (first.disjoined(second) == bsFalse) ? bsFalse : bsUnknown;

  BSLogical _testRosterElements(
      SplayTreeSet<BSFunction> elements, BSSet other) {
    for (var element in elements) {
      if (other.belongs(element)) return bsFalse;
    }
    return bsTrue;
  }

  @override
  BSLogical operateBuilderSetBuilderSet(BuilderSet first, BuilderSet second) =>
      _disjoinedPositivesAsUnknown(first.knownElements, second.knownElements);

  @override
  BSLogical operateIntensionalSetIntersectionBuilderSet(
          IntensionalSetIntersection first, BuilderSet second) =>
      _disjoinedPositivesAsUnknown(first, second.knownElements);

  @override
  BSLogical operateIntensionalSetIntersectionIntensionalSetIntersection(
          IntensionalSetIntersection first,
          IntensionalSetIntersection second) =>
      _disjoinedPositivesAsUnknown(first.knownElements, second.knownElements);

  @override
  BSLogical operateIntervalBuilderSet(Interval first, BuilderSet second) =>
      _disjoinedPositivesAsUnknown(first, second.knownElements);

  @override
  BSLogical operateIntervalIntensionalSetIntersection(
          Interval first, IntensionalSetIntersection second) =>
      _disjoinedPositivesAsUnknown(first, second.knownElements);

  @override
  BSLogical operateIntervalInterval(
          Interval first,
          Interval
              second) => //one of the intervals has to have all its elements before the other one
      ((first.b < second.a) ||
              (second.b < first.a) ||
              //or the two share an edge, but one of them doesn't include it
              (first.b == second.a &&
                  (!first.rightClosed || !second.leftClosed)) ||
              (first.a == second.b &&
                  (!first.leftClosed || !second.rightClosed)))
          ? bsTrue
          : bsFalse;

  @override
  BSLogical operateRosterSetBuilderSet(RosterSet first, BuilderSet second) =>
      _testRosterElements(first.elements, second);

  @override
  BSLogical operateRosterSetIntensionalSetIntersection(
          RosterSet first, IntensionalSetIntersection second) =>
      _testRosterElements(first.elements, second);

  @override
  BSLogical operateRosterSetInterval(RosterSet first, Interval second) =>
      _testRosterElements(first.elements, second);

  @override
  BSLogical operateRosterSetRosterSet(RosterSet first, RosterSet second) =>
      _testRosterElements(first.elements, second);

  BSLogical _testSubsets(List<BSSet> subsets, BSSet other) {
    for (var subset in subsets) {
      BSLogical disjoined = subset.disjoined(other);
      if (disjoined != bsTrue) return disjoined;
    }
    return bsTrue;
  }

  @override
  BSLogical operateSetUnionBuilderSet(SetUnion first, BuilderSet second) =>
      _testSubsets(first.subsets, second);

  @override
  BSLogical operateSetUnionIntensionalSetIntersection(
          SetUnion first, IntensionalSetIntersection second) =>
      _testSubsets(first.subsets, second);

  @override
  BSLogical operateSetUnionInterval(SetUnion first, Interval second) =>
      _testSubsets(first.subsets, second);

  @override
  BSLogical operateSetUnionRosterSet(SetUnion first, RosterSet second) =>
      _testSubsets(first.subsets, second);

  @override
  BSLogical operateSetUnionSetUnion(SetUnion first, SetUnion second) =>
      _testSubsets(first.subsets, second);

  @override
  BSLogical onEmpty(BSSet first, BSSet second) => bsTrue;
}
