import 'dart:collection';

import '../sets.dart';
import '../../logic/logic.dart';
import '../../utils/method_table.dart';
import '../../function/functions.dart';

//If we get to this function, we already now the sets are not disjoined
ComutativeMethodTable<BSSet, BSSet> defineUnionTable() {
  ComutativeMethodTable<BSSet, BSSet> methods = ComutativeMethodTable();

  methods.addMethod(Interval, Interval, (Interval first, Interval second) {
    //calls constructor directly instead of builder function because we already know the sets are disjoint
    if (first.disjoined(second).asBool()) return SetUnion([first, second]);
    BSFunction _a = BSFunction.min(first.a, second.a);
    BSFunction _b = BSFunction.max(first.b, second.b);

    bool _leftClosed;
    if (first.a == second.a) {
      _leftClosed = first.leftClosed || second.leftClosed;
    } else {
      _leftClosed = first.a < second.a ? first.leftClosed : second.leftClosed;
    }

    bool _rightClosed;
    if (first.b == second.b) {
      _rightClosed = first.rightClosed || second.rightClosed;
    } else {
      _rightClosed =
          first.b > second.b ? first.rightClosed : second.rightClosed;
    }

    return interval(_a, _b, leftClosed: _leftClosed, rightClosed: _rightClosed);
  });

  methods.addMethodsInColumn(
      [Interval, RosterSet, BuilderSet, IntensionalSetIntersection], SetUnion,
      (BSSet first, SetUnion second) {
    List<BSSet> _new = second.subsets.toList();
    _new.add(first);
    //Delegates to the SetUnion factory function for simplifications
    return SetUnion(_new);
  });

  methods.addMethod(Interval, RosterSet, (Interval first, RosterSet second) {
    //checks if we can "close" an interval edge with the elements of the roster set.
    first = interval(first.a, first.b,
        leftClosed: first.leftClosed || second.belongs(first.a),
        rightClosed: first.rightClosed || second.belongs(first.b));

    BSSet _second =
        rosterSet(second.elements.where((element) => !first.belongs(element)));
    if (_second == emptySet) {
      return first;
    } else {
      return SetUnion([first, _second]);
    }
  });

  //Uses the native set implementation to filter out repeated elements
  methods.addMethod(RosterSet, RosterSet, (RosterSet first, RosterSet second) {
    SplayTreeSet<BSFunction> _new = SplayTreeSet.from(first.elements);
    _new.addAll(second.elements);
    RosterSet(_new);
  });

  methods.addMethod(SetUnion, SetUnion, (SetUnion first, SetUnion second) {
    List<BSSet> _new = first.subsets.toList();
    _new.addAll(second.subsets);
    //Delegates to the SetUnion factory function for simplifications
    return SetUnion(_new);
  });

  //we can't trust the BuilderSet to properly give us every solution to it, so we can't really remove it unless we have
  //absolute certainty it is correct, and in these cases the BuilderSet will simplify to another set anyway. So, for BuilderSets with other things,
  //all we can do is remove the values that are solutions from the other set
  methods.addMethodsInColumn([Interval, RosterSet], BuilderSet,
      (BSSet first, BuilderSet second) {
    return SetUnion([second, first.relativeComplement(second.knownElements)]);
  });

  //fix parameters
  methods.addMethod(BuilderSet, BuilderSet,
      (BuilderSet first, BuilderSet second) {
    return builderSet(Or(first.rule, second.rule), null);
  });

  methods.addMethodsInColumn(
      [Interval, RosterSet, BuilderSet, IntensionalSetIntersection],
      IntensionalSetIntersection,
      (BSSet first, IntensionalSetIntersection second) =>
          setUnion([first, second]));

  return methods;
}
