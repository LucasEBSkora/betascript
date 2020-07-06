import '../../Utils/MethodTable.dart';
import '../sets.dart';
import '../../BSFunction/BSCalculus.dart';

MethodTable<bool, BSSet> defineContainsTable() {
  MethodTable<bool, BSSet> methods;

  methods.addMethod(
      Interval,
      Interval,
      (Interval first, Interval second) =>
          (first.belongs(second.a) ||
              (first.a == second.a &&
                  (first.leftClosed || !second.leftClosed))) &&
          (first.belongs(second.b) ||
              (first.a == second.a &&
                  (first.rightClosed || !second.rightClosed))));

  methods.addMethod(
      //all subsets of second need to be contained in first
      Interval,
      DisjoinedSetUnion,
      (Interval first, DisjoinedSetUnion second) => second.subsets.fold(
          true,
          (previousValue, element) =>
              previousValue && first.contains(element)));
  methods.addMethod(
      //all elements of second need to be belong to first
      Interval,
      RosterSet,
      (Interval first, RosterSet second) => second.elements.fold(true,
          (previousValue, element) => previousValue && first.belongs(element)));

  return methods;
}
