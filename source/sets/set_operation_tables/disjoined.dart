import '../sets.dart';
import '../../utils/method_table.dart';

ComutativeMethodTable<bool, BSSet> defineDisjoinedTable() {
  ComutativeMethodTable<bool, BSSet> methods = ComutativeMethodTable();

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

  //looks for any elements of second not disjoined with first
  methods.addMethodsInColumn(
      [
        Interval,
        RosterSet,
        BuilderSet,
        SetUnion,
      ],
      SetUnion,
      (BSSet first, SetUnion second) =>
          second.subsets.firstWhere((element) => !element.disjoined(first),
              orElse: () => null) ==
          null);

  //looks for any elements of first contained in second.
  //if it doesn't find any, the sets are disjoined
  methods.addMethodsInLine(
      RosterSet,
      [Interval, RosterSet, BuilderSet, IntensionalSetIntersection],
      (RosterSet first, BSSet second) =>
          first.elements.firstWhere((value) => second.belongs(value),
              orElse: () => null) ==
          null);

  //no idea, but following the philosophy of "false negatives over false positives", we'll just assume
  //that the sets are joined for now
  methods.addMethod(
      Interval, BuilderSet, (Interval first, BuilderSet second) => false);

  methods.addMethod(
      BuilderSet, BuilderSet, (BuilderSet first, BuilderSet second) => false);

  methods.addMethodsInColumn(
      [Interval, BuilderSet, IntensionalSetIntersection],
      IntensionalSetIntersection,
      (BSSet first, IntensionalSetIntersection second) => false);

  return methods;
}
