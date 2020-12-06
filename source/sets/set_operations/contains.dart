import '../../utils/three_valued_logic.dart';
import '../empty_set.dart';
import '../sets.dart';
import 'set_operation.dart';

///returns whether FIRST CONTAINS SECOND: first ⊃ second
class Contains extends SetOperation<BSLogical> {

  @override
  BSLogical operateBuilderSetBuilderSet(BuilderSet first, BuilderSet second) =>
      bsUnknown;

  @override
  BSLogical operateBuilderSetEmptySet(BuilderSet first, EmptySet second) =>
      bsTrue;

  //TODO: slightly wrong
  @override
  BSLogical operateBuilderSetIntensionalSetIntersection(
          BuilderSet first, IntensionalSetIntersection second) =>
      first.contains(second.first) & first.contains(second.second);

  @override
  BSLogical operateBuilderSetInterval(BuilderSet first, Interval second) =>
      (first.knownElements.contains(second).asBool()) ? bsTrue : bsUnknown;

  @override
  BSLogical operateBuilderSetRosterSet(BuilderSet first, RosterSet second) {
    for (var element in second.elements) {
      if (!first.belongs(element)) return bsFalse;
    }
    return bsTrue;
  }

  @override
  BSLogical operateBuilderSetSetUnion(BuilderSet first, SetUnion second) {
    for (var element in second.subsets) {
      BSLogical _contains = first.contains(element);
      if (!_contains.asBool()) return _contains;
    }
    return bsTrue;
  }

  //needs to check if
  @override
  BSLogical operateEmptySetBuilderSet(EmptySet first, BuilderSet second) =>
      (second.knownElements != emptySet) ? bsFalse : bsUnknown;

  @override
  BSLogical operateEmptySetEmptySet(EmptySet first, EmptySet second) => bsTrue;

  //TODO:: Needs to go through the tree properly - make a visitor to check for elements
  @override
  BSLogical operateEmptySetIntensionalSetIntersection(
      EmptySet first, IntensionalSetIntersection second) {
    final left = second.first;
    final right = second.second;
    if (left is BuilderSet && right is BuilderSet) {
      if (left.knownElements == emptySet && right.knownElements == emptySet)
        return bsUnknown;
    }
    return bsFalse;
  }

  @override
  BSLogical operateEmptySetInterval(EmptySet first, Interval second) => bsFalse;

  @override
  BSLogical operateEmptySetRosterSet(EmptySet first, RosterSet second) =>
      bsFalse;

  //TODO: needs to go through the tree
  @override
  BSLogical operateEmptySetSetUnion(EmptySet first, SetUnion second) => bsFalse;

  @override
  BSLogical operateIntensionalSetIntersectionBuilderSet(
          IntensionalSetIntersection first, BuilderSet second) =>
      bsUnknown;

  @override
  BSLogical operateIntensionalSetIntersectionEmptySet(
          IntensionalSetIntersection first, EmptySet second) =>
      bsTrue;

  //TODO: think about this one
  @override
  BSLogical operateIntensionalSetIntersectionIntensionalSetIntersection(
          IntensionalSetIntersection first,
          IntensionalSetIntersection second) =>
      bsUnknown;

  @override
  BSLogical operateIntensionalSetIntersectionInterval(
          IntensionalSetIntersection first, Interval second) =>
      first.first.contains(second) & first.second.contains(second);

  @override
  BSLogical operateIntensionalSetIntersectionRosterSet(
      IntensionalSetIntersection first, RosterSet second) {
    for (var element in second.elements) {
      if (!first.belongs(element)) return bsFalse;
    }
    return bsTrue;
  }

  @override
  BSLogical operateIntensionalSetIntersectionSetUnion(
      IntensionalSetIntersection first, SetUnion second) {
    for (var element in second.subsets) {
      BSLogical _contains = first.contains(element);
      if (_contains != bsTrue) return _contains;
    }
    return bsTrue;
  }

  @override
  BSLogical operateIntervalBuilderSet(Interval first, BuilderSet second) =>
      bsUnknown;

  @override
  BSLogical operateIntervalEmptySet(Interval first, EmptySet second) => bsTrue;

  @override
  BSLogical operateIntervalIntensionalSetIntersection(
          Interval first, IntensionalSetIntersection second) =>
      first.contains(second.first) & first.contains(second.second);

  @override
  BSLogical operateIntervalInterval(Interval first, Interval second) =>
      ((first.belongs(second.a) ||
                  (first.a == second.a &&
                      (first.leftClosed || !second.leftClosed))) &&
              (first.belongs(second.b) ||
                  (first.b == second.b &&
                      (first.rightClosed || !second.rightClosed))))
          ? bsTrue
          : bsFalse;

  @override
  BSLogical operateIntervalRosterSet(Interval first, RosterSet second) {
    for (var element in second.elements) {
      if (!first.belongs(element)) return bsFalse;
    }
    return bsTrue;
  }

  @override
  BSLogical operateIntervalSetUnion(Interval first, SetUnion second) {
    for (var element in second.subsets) {
      BSLogical _contains = first.contains(element);
      if (_contains != bsTrue) return _contains;
    }
    return bsTrue;
  }

  @override
  BSLogical operateRosterSetBuilderSet(RosterSet first, BuilderSet second) =>
      bsUnknown;

  @override
  BSLogical operateRosterSetEmptySet(RosterSet first, EmptySet second) =>
      bsTrue;

  @override
  BSLogical operateRosterSetIntensionalSetIntersection(
          RosterSet first, IntensionalSetIntersection second) =>
      first.contains(second.first) & first.contains(second.second);

  @override
  BSLogical operateRosterSetInterval(RosterSet first, Interval second) =>
      bsFalse;

  @override
  BSLogical operateRosterSetRosterSet(RosterSet first, RosterSet second) {
    for (var element in second.elements) {
      if (!first.belongs(element)) return bsFalse;
    }
    return bsTrue;
  }

  @override
  BSLogical operateRosterSetSetUnion(RosterSet first, SetUnion second) {
    for (var element in second.subsets) {
      BSLogical _contains = first.contains(element);
      if (_contains != bsTrue) return _contains;
    }
    return bsTrue;
  }

  @override
  BSLogical operateSetUnionBuilderSet(SetUnion first, BuilderSet second) =>
      second.relativeComplement(first) == emptySet ? bsTrue : bsFalse;

  @override
  BSLogical operateSetUnionEmptySet(SetUnion first, EmptySet second) => bsTrue;

  @override
  BSLogical operateSetUnionIntensionalSetIntersection(
          SetUnion first, IntensionalSetIntersection second) =>
      second.relativeComplement(first) == emptySet ? bsTrue : bsFalse;

  @override
  BSLogical operateSetUnionInterval(SetUnion first, Interval second) =>
      second.relativeComplement(first) == emptySet ? bsTrue : bsFalse;

  @override
  BSLogical operateSetUnionRosterSet(SetUnion first, RosterSet second) =>
      second.relativeComplement(first) == emptySet ? bsTrue : bsFalse;

  @override
  BSLogical operateSetUnionSetUnion(SetUnion first, SetUnion second) {
    for (var element in second.subsets) {
      BSLogical _contains = first.contains(element);
      if (_contains != bsTrue) return _contains;
    }
    return bsTrue;
  }
}