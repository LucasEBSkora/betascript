import 'dart:collection';

import '../sets.dart';
import '../../logic/logic.dart';
import '../../utils/method_table.dart';
import '../../βs_function/βs_calculus.dart';

ComutativeMethodTable<BSSet, BSSet> defineIntersectionTable() {
  ComutativeMethodTable<BSSet, BSSet> methods = ComutativeMethodTable();

  methods.addMethod(Interval, Interval, (Interval first, Interval second) {
    BSFunction _a = BSFunction.max(first.a, second.a);
    BSFunction _b = BSFunction.min(first.b, second.b);

    bool _leftClosed;
    if (first.a == second.a) {
      _leftClosed = first.leftClosed && second.leftClosed;
    } else {
      _leftClosed = first.a > second.a ? first.leftClosed : second.leftClosed;
    }

    bool _rightClosed;
    if (first.b == second.b) {
      _rightClosed = first.rightClosed && second.rightClosed;
    } else {
      _rightClosed =
          first.b < second.b ? first.rightClosed : second.rightClosed;
    }

    return interval(_a, _b, leftClosed: _leftClosed, rightClosed: _rightClosed);
  });

  methods.addMethod(
      Interval,
      RosterSet,
      (Interval first, RosterSet second) => rosterSet(
          second.elements.where((element) => first.belongs(element))));

  methods.addMethodsInColumn(
      //Depends on the simplifications to remove empty sets that remain
      [Interval, RosterSet, BuilderSet],
      SetUnion,
      (Interval first, SetUnion second) =>
          SetUnion(second.subsets.map((e) => first.intersection(e))));

  //IntensionalSetIntersections always have exactly one member that is a BuilderSet,
  //so we take the one that isn't and intersect it with the rest
  methods.addMethod(
      IntensionalSetIntersection,
      SetUnion,
      (IntensionalSetIntersection first, SetUnion second) =>
          (first.first is BuilderSet)
              ? IntensionalSetIntersection(
                  second.intersection(first.second), first.first)
              : IntensionalSetIntersection(
                  second.intersection(first.first), first.second));

  methods.addMethod(SetUnion, SetUnion, (SetUnion first, SetUnion second) {
    List<BSSet> _new = List();
    //computes the union of the intersections of second
    //with each set in first
    first.subsets.forEach((element) => _new.add(second.intersection(element)));

    return SetUnion(_new);
  });

  methods.addMethod(
      RosterSet,
      RosterSet,
      (RosterSet first, RosterSet second) => RosterSet(
          first.elements.where((element) => second.belongs((element)))));

  //since we can't find every member of the builder set, we can't really simplify this
  //all we can do in this case is remove the edges of the interval if they are not
  //members of the builder set
  methods.addMethod(
      Interval,
      BuilderSet,
      (Interval first, BuilderSet second) => IntensionalSetIntersection(
          interval(first.a, first.b,
              leftClosed: first.leftClosed && second.belongs(first.a),
              rightClosed: first.rightClosed && second.belongs(first.b)),
          second));

  methods.addMethod(
      RosterSet,
      BuilderSet,
      (RosterSet first, BuilderSet second) => RosterSet(first.elements.where(
          (element) => second.rule.isSolution(
              HashMap.from({second.rule.parameters.last: element})))));

  //TODO: fix parameters
  methods.addMethod(
      BuilderSet,
      BuilderSet,
      (BuilderSet first, BuilderSet second) =>
          builderSet(And(first.rule, second.rule), null));

  // (A ∩ B) ∩ C = A ∩ (B ∩ C) = B ∩ (A ∩ C)

  methods.addMethodsInColumn(
      [Interval, RosterSet, BuilderSet, IntensionalSetIntersection],
      IntensionalSetIntersection,
      (BSSet first, IntensionalSetIntersection second) {
    if (second.first is BuilderSet) {
      return IntensionalSetIntersection(
          second.second.intersection(first), second.first);
    } else if (second.second is BuilderSet) {
      return IntensionalSetIntersection(
          second.first.intersection(first), second.second);
    }
  });

  return methods;
}
