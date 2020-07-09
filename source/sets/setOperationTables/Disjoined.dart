import '../../Utils/MethodTable.dart';
import '../sets.dart';

ComutativeMethodTable<bool, BSSet> defineDisjoinedTable() {
  ComutativeMethodTable<bool, BSSet> methods;

  methods.addMethod(
      Interval,
      Interval,
      (Interval first,
              Interval
                  second) => //one of the intervals has to have all its elements before the other one
          (first.b < second.a) ||
          (second.b < first.a) ||
          //or the two share an edge, but one of them doesn't include it
          (first.b == second.a && (!first.rightClosed || !second.leftClosed)) ||
          (first.a == second.b && (!first.leftClosed || !second.rightClosed)));

  //looks for any elements of second contained in first. if it doesn't find any, the sets are disjoined
  methods.addMethod(
      Interval,
      RosterSet,
      (Interval first, RosterSet second) =>
          second.elements.firstWhere((value) => first.belongs(value),
              orElse: () => null) ==
          null);

  //looks for any elements of second no disjoined with first
  methods.addMethodsInColumn(
      [Interval, RosterSet, BuilderSet, DisjoinedSetUnion],
      DisjoinedSetUnion,
      (BSSet first, DisjoinedSetUnion second) =>
          second.subsets.firstWhere((element) => !element.disjoined(first),
              orElse: () => null) ==
          null);

  methods.addMethod(
      RosterSet,
      RosterSet,
      (RosterSet first, RosterSet second) =>
          first.elements.firstWhere((value) => second.belongs(value),
              orElse: () => null) ==
          null);
  return methods;
}
