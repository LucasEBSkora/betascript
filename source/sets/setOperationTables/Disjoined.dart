import '../../Utils/MethodTable.dart';
import '../sets.dart';
import '../../BSFunction/BSCalculus.dart';

ComutativeMethodTable<bool, BSSet> defineDisjoinedTable() {
  ComutativeMethodTable<bool, BSSet> methods;

  methods.addMethod(
      Interval,
      Interval,
      (Interval first,
              Interval
                  second) => //one of the intervals has to have all its elements before the other one
          (first.b < second.a) ||
          (second.b < first.b) ||
          //or the two share an edge, but one of them doesn't include it
          (first.b == second.a && (!first.rightClosed || !second.leftClosed)) ||
          (first.a == second.b && (!first.leftClosed || !second.rightClosed)));
  methods.addMethod(
      Interval,
      DisjoinedSetUnion,
      (Interval first, DisjoinedSetUnion second) => second.subsets.fold(
          true,
          (previousValue, element) =>
              previousValue && first.disjoined(element)));
              
  methods.addMethod(
      Interval,
      RosterSet,
      (Interval first, RosterSet second) => second.elements.fold(
          true,
          (previousValue, element) =>
              previousValue && !first.belongs(element)));

  return methods;
}
