import '../../utils/method_table.dart';
import '../../utils/three_valued_logic.dart';
import '../sets.dart';

MethodTable<BSLogical, BSSet> defineContainsTable() {
  MethodTable<BSLogical, BSSet> methods = MethodTable();

  methods.addMethod(
      Interval,
      Interval,
      (Interval first, Interval second) => ((first.belongs(second.a) ||
                  (first.a == second.a &&
                      (first.leftClosed || !second.leftClosed))) &&
              (first.belongs(second.b) ||
                  (first.b == second.b &&
                      (first.rightClosed || !second.rightClosed))))
          ? bsTrue
          : bsFalse);

  //all subsets of second need to be contained in first
  methods.addMethodsInColumn(
      [Interval, RosterSet, BuilderSet, SetUnion, IntensionalSetIntersection],
      SetUnion, (BSSet first, SetUnion second) {
    for (var element in second.subsets) {
      BSLogical _contains = first.contains(element);
      if (_contains != bsTrue) return _contains;
    }
    return bsTrue;
  });

  methods.addMethodsInColumn(
      //all elements of second need to be belong to first
      [Interval, RosterSet, BuilderSet, IntensionalSetIntersection], RosterSet,
      (BSSet first, RosterSet second) {
    for (var element in second.elements) {
      if (!first.belongs(element)) return bsFalse;
    }
    return bsTrue;
  });

  //doesn't need to check anything because an Interval with a single element (e.g., [a, a]) is already created as a single
  //element roster set
  methods.addMethod(
      RosterSet, Interval, (RosterSet first, Interval second) => bsFalse);

  //checks if the intersection of first and the complement of second is empty
  methods.addMethodsInLine(
      SetUnion,
      [Interval, RosterSet, BuilderSet],
      (SetUnion first, BSSet second) =>
          second.relativeComplement(first) == emptySet ? bsTrue : bsFalse);

  //will return false negatives:
  //if A = B ∩ C and D contains B and C, then D contains A
  //however, the reciprocal is not true
  //TODO: fix this as well, it should return appropriate values
  methods.addMethodsInColumn(
      [Interval, RosterSet, BuilderSet, SetUnion, IntensionalSetIntersection],
      IntensionalSetIntersection,
      (BSSet first, IntensionalSetIntersection second) {
    return first.contains(second.first) & first.contains(second.second);
  });

  //if A = B ∩ C and B and C contain D, then A contains D
  methods.addMethod(
      IntensionalSetIntersection,
      Interval,
      (IntensionalSetIntersection first, Interval second) =>
          first.first.contains(second) & first.second.contains(second));

  methods.addMethod(
      BuilderSet,
      Interval,
      (BuilderSet first, Interval second) =>
          first.knownElements.contains(second));

  //can't be sure
  methods.addMethod(
      Interval, BuilderSet, (Interval first, BuilderSet second) => bsUnknown);

  methods.addMethod(
      RosterSet, BuilderSet, (RosterSet first, BuilderSet second) => bsUnknown);

  methods.addMethod(
      BuilderSet, BuilderSet, (BuilderSet first, BuilderSet second) => bsUnknown);

  return methods;
}
