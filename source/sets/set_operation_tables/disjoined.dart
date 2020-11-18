import '../sets.dart';
import '../../utils/three_valued_logic.dart';
import '../../utils/method_table.dart';

ComutativeMethodTable<BSLogical, BSSet> defineDisjoinedTable() {
  ComutativeMethodTable<BSLogical, BSSet> methods = ComutativeMethodTable();

  methods.addMethod(
      Interval,
      Interval,
      (Interval first,
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
              : bsFalse);

  //looks for any elements of second not disjoined with first
  methods.addMethodsInColumn([
    Interval,
    RosterSet,
    BuilderSet,
    SetUnion,
  ], SetUnion, (BSSet first, SetUnion second) {
    for (var subset in second.subsets) {
      BSLogical disjoined = subset.disjoined(first);
      if (disjoined != bsTrue) return disjoined;
    }
    return bsTrue;
  });

  //looks for any elements of first contained in second.
  //if it doesn't find any, the sets are disjoined
  methods.addMethodsInLine(
      RosterSet,
      [Interval, RosterSet, BuilderSet, IntensionalSetIntersection],
      (RosterSet first, BSSet second) {
          for (var element in first.elements) {
            if (second.belongs(element)) return bsFalse;
          }
          return bsTrue;
      });

  methods.addMethod(
      Interval, BuilderSet, (Interval first, BuilderSet second) => bsUnknown);

  methods.addMethod(BuilderSet, BuilderSet,
      (BuilderSet first, BuilderSet second) => bsUnknown);

  methods.addMethodsInColumn(
      [Interval, BuilderSet, IntensionalSetIntersection],
      IntensionalSetIntersection,
      (BSSet first, IntensionalSetIntersection second) => bsUnknown);

  return methods;
}
