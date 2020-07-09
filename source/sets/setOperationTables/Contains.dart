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
      [Interval, RosterSet, BuilderSet, DisjoinedSetUnion], DisjoinedSetUnion,
      (BSSet first, DisjoinedSetUnion second) {
    for (var element in second.subsets)
      if (!first.contains(element)) return false;

    return true;
  });
  methods.addMethod(
      //all elements of second need to be belong to first
      Interval,
      RosterSet,
      (Interval first, RosterSet second) => second.elements.fold(true,
          (previousValue, element) => previousValue && first.belongs(element)));

  //doesn't need to check anything because an Interval with a single element (e.g., [a, a]) is already created as a single
  //element roster set
  methods.addMethod(
      RosterSet, Interval, (RosterSet first, Interval second) => false);

  methods.addMethod(RosterSet, RosterSet, (RosterSet first, RosterSet second) {
    for (var element in second.elements) {
      if (!first.elements.contains(element)) return false;
    }
    return true;
  });

  //checks if the intersection of first' and second is empty
  methods.addMethodsInLine(
      DisjoinedSetUnion,
      [Interval, RosterSet, BuilderSet],
      (DisjoinedSetUnion first, BSSet second) =>
          second.relativeComplement(first) == emptySet);

  return methods;
}
