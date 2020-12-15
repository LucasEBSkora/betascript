import '../../utils/three_valued_logic.dart';
import '../empty_set.dart';
import '../sets.dart';
import 'set_operation.dart';

///returns whether FIRST CONTAINS SECOND: first ⊃ second
class Contains extends EmptyTreatingSetOperation<BSLogical> {
  @override
  BSLogical operateBuilderSetBuilderSet(BuilderSet first, BuilderSet second) =>
      bsUnknown;

  @override
  BSLogical operateBuilderSetEmptySet(BuilderSet first, EmptySet second) =>
      bsTrue;

  //if it contains both, it definetely contains the intersection. otherwise, can't really be sure
  @override
  BSLogical operateBuilderSetIntensionalSetIntersection(
          BuilderSet first, IntensionalSetIntersection second) =>
      ((first.contains(second.first) & first.contains(second.second)).asBool())
          ? bsTrue
          : bsUnknown;

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

  //needs to check if any of the elements of
  @override
  BSLogical operateEmptySetBuilderSet(EmptySet first, BuilderSet second) =>
      (second.knownElements != emptySet) ? bsFalse : bsUnknown;

  @override
  BSLogical operateEmptySetEmptySet(EmptySet first, EmptySet second) => bsTrue;

  @override
  BSLogical operateEmptySetIntensionalSetIntersection(
          EmptySet first, IntensionalSetIntersection second) =>
      (second.knownElements != emptySet) ? bsUnknown : bsFalse;

  @override
  BSLogical operateEmptySetInterval(EmptySet first, Interval second) => bsFalse;

  @override
  BSLogical operateEmptySetRosterSet(EmptySet first, RosterSet second) =>
      bsFalse;

  @override
  BSLogical operateEmptySetSetUnion(EmptySet first, SetUnion second) =>
      (second.isIntensional && second.knownElements == emptySet)
          ? bsUnknown
          : bsFalse;

  //basically impossible to simplify
  @override
  BSLogical operateIntensionalSetIntersectionBuilderSet(
          IntensionalSetIntersection first, BuilderSet second) =>
      bsUnknown;

  @override
  BSLogical operateIntensionalSetIntersectionEmptySet(
          IntensionalSetIntersection first, EmptySet second) =>
      bsTrue;

  //basically impossible to simplify
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
      (first.contains(second.knownElements) == bsFalse) ? bsFalse : bsUnknown;

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
      (first.contains(second.knownElements) == bsFalse) ? bsFalse : bsUnknown;

  @override
  BSLogical operateRosterSetEmptySet(RosterSet first, EmptySet second) =>
      bsTrue;

  @override
  BSLogical operateRosterSetIntensionalSetIntersection(
          RosterSet first, IntensionalSetIntersection second) =>
      (first.contains(second.knownElements) == bsFalse) ? bsFalse : bsUnknown;

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
      (first.isIntensional &&
              second.knownElements.relativeComplement(first) != emptySet)
          ? bsFalse
          : bsUnknown;

  @override
  BSLogical operateSetUnionEmptySet(SetUnion first, EmptySet second) => bsTrue;

  @override
  BSLogical operateSetUnionIntensionalSetIntersection(
          SetUnion first, IntensionalSetIntersection second) =>
      (first.isIntensional &&
              second.knownElements.relativeComplement(first) != emptySet)
          ? bsFalse
          : bsUnknown;

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
