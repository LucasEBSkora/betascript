import '../../Utils/MethodTable.dart';
import '../sets.dart';

MethodTable<bool, BSSet> defineContainsTable() {
  MethodTable<bool, BSSet> methods = MethodTable();

  methods.addMethod(
      Interval,
      Interval,
      (Interval first, Interval second) =>
          (first.belongs(second.a) ||
              (first.a == second.a &&
                  (first.leftClosed || !second.leftClosed))) &&
          (first.belongs(second.b) ||
              (first.b == second.b &&
                  (first.rightClosed || !second.rightClosed))));

  //all subsets of second need to be contained in first
  methods.addMethodsInColumn(
      [Interval, RosterSet, BuilderSet, SetUnion, IntensionalSetIntersection],
      SetUnion, (BSSet first, SetUnion second) {
    for (var element in second.subsets)
      if (!first.contains(element)) return false;

    return true;
  });

  methods.addMethodsInColumn(
      //all elements of second need to be belong to first
      [Interval, RosterSet, BuilderSet, IntensionalSetIntersection],
      RosterSet,
      (Interval first, RosterSet second) => second.elements.fold(true,
          (previousValue, element) => previousValue && first.belongs(element)));

  //doesn't need to check anything because an Interval with a single element (e.g., [a, a]) is already created as a single
  //element roster set
  methods.addMethod(
      RosterSet, Interval, (RosterSet first, Interval second) => false);

  //checks if the intersection of first and the complement of second is empty
  methods.addMethodsInLine(
      SetUnion,
      [Interval, RosterSet, BuilderSet],
      (SetUnion first, BSSet second) =>
          second.relativeComplement(first) == emptySet);

  //will return false negatives:
  //if A = B ∩ C and D contains B and C, then D contains A
  //however, the reciprocal is not true
  methods.addMethodsInColumn(
      [Interval, RosterSet, BuilderSet, SetUnion, IntensionalSetIntersection],
      IntensionalSetIntersection,
      (BSSet first, IntensionalSetIntersection second) {
    return first.contains(second.first) && first.contains(second.second);
  });

  //if A = B ∩ C and B and C contain D, then A contains D
  methods.addMethod(
      IntensionalSetIntersection,
      Interval,
      (IntensionalSetIntersection first, Interval second) =>
          first.first.contains(second) && first.second.contains(second));

  methods.addMethod(
      BuilderSet,
      Interval,
      (BuilderSet first, Interval second) =>
          first.knownElements.contains(second));

  //can't be sure
  methods.addMethod(
      Interval, BuilderSet, (Interval first, BuilderSet second) => false);

  methods.addMethod(
      RosterSet, BuilderSet, (RosterSet first, BuilderSet second) => false);

  methods.addMethod(
      BuilderSet, BuilderSet, (BuilderSet first, BuilderSet second) => false);

  return methods;
}
