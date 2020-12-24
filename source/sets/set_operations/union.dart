import 'dart:collection';

import '../empty_set.dart';
import '../sets.dart';
import '../../logic/logic.dart';
import '../../function/functions.dart';
import 'set_operation.dart';

class Union extends EmptyFilteringComutativeSetOperation<BSSet> {
  @override
  BSSet operateBuilderSetBuilderSet(BuilderSet first, BuilderSet second) =>
      builderSet(Or(first.rule, second.rule),
          <Variable>[...first.parameters, ...second.parameters]);

  @override
  BSSet operateIntensionalSetIntersectionBuilderSet(
          IntensionalSetIntersection first, BuilderSet second) =>
      setUnion([first, second]);

  @override
  BSSet operateIntensionalSetIntersectionIntensionalSetIntersection(
          IntensionalSetIntersection first,
          IntensionalSetIntersection second) =>
      setUnion([first, second]);

  //we can't trust the BuilderSet to properly give us every solution to it,
  //so we can't really remove it unless we have absolute certainty it is correct,
  //and in these cases the BuilderSet will simplify to another set anyway.
  //So, for BuilderSets with other things, all we can do is remove the values
  //that are solutions from the other set
  @override
  BSSet operateIntervalBuilderSet(Interval first, BuilderSet second) =>
      SetUnion([second, first.relativeComplement(second.knownElements)]);

  @override
  BSSet operateIntervalIntensionalSetIntersection(
          Interval first, IntensionalSetIntersection second) =>
      setUnion([first, second]);

  @override
  BSSet operateIntervalInterval(Interval first, Interval second) {
    //calls constructor directly instead of builder function because we already know the sets are disjoint
    if (first.disjoined(second).asBool()) return SetUnion([first, second]);
    BSFunction _a = min(first.a, second.a);
    BSFunction _b = max(first.b, second.b);

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
  }

  //see operateIntervalBuilderSet
  @override
  BSSet operateRosterSetBuilderSet(RosterSet first, BuilderSet second) =>
      SetUnion([second, first.relativeComplement(second.knownElements)]);

  @override
  BSSet operateRosterSetIntensionalSetIntersection(
          RosterSet first, IntensionalSetIntersection second) =>
      setUnion([first, second]);

  @override
  BSSet operateRosterSetInterval(RosterSet first, Interval second) {
    //checks if we can "close" an interval edge with the elements of the roster set.
    second = interval(second.a, second.b,
        leftClosed: second.leftClosed || first.belongs(second.a),
        rightClosed: second.rightClosed || first.belongs(second.b));

    BSSet _second =
        rosterSet(first.elements.where((element) => !first.belongs(element)));
    if (_second == emptySet) {
      return first;
    } else {
      return SetUnion([first, _second]);
    }
  }

  //delegates to the set implementation to remove duplicates
  @override
  BSSet operateRosterSetRosterSet(RosterSet first, RosterSet second) =>
      RosterSet(SplayTreeSet<BSFunction>.from(
          <BSFunction>{...first.elements, ...second.elements}));

  @override
  BSSet operateSetUnionBuilderSet(SetUnion first, BuilderSet second) =>
      setUnion([...first.subsets, second]);

  @override
  BSSet operateSetUnionIntensionalSetIntersection(
          SetUnion first, IntensionalSetIntersection second) =>
      setUnion([...first.subsets, second]);

  @override
  BSSet operateSetUnionInterval(SetUnion first, Interval second) =>
      setUnion([...first.subsets, second]);

  @override
  BSSet operateSetUnionRosterSet(SetUnion first, RosterSet second) =>
      setUnion([...first.subsets, second]);

  @override
  BSSet operateSetUnionSetUnion(SetUnion first, SetUnion second) =>
      setUnion([...first.subsets, ...second.subsets]);

  @override
  BSSet onEmpty(BSSet first, BSSet second) =>
      (first == emptySet) ? second : first;
}
