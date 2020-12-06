import '../empty_set.dart';
import '../sets.dart';
import '../../logic/logic.dart';
import '../../function/functions.dart';
import 'set_operation.dart';

class Intersection extends ComutativeSetOperation<BSSet> {
  @override
  BSSet operateBuilderSetBuilderSet(BuilderSet first, BuilderSet second) =>
      builderSet(And(first.rule, second.rule),
          <Variable>[...first.parameters, ...second.parameters]);

  @override
  BSSet operateEmptySetBuilderSet(EmptySet first, BuilderSet second) =>
      emptySet;

  @override
  BSSet operateEmptySetEmptySet(EmptySet first, EmptySet second) => emptySet;

  BSSet _groupNotIntensional(BSSet first, BSSet second, BSSet other) {
    if (first is BuilderSet) {
      return IntensionalSetIntersection(first, second.intersection(other));
    } else {
      return IntensionalSetIntersection(second, first.intersection(other));
    }
  }

  BSSet _groupIntensional(BSSet first, BSSet second, BSSet other) {
    if (first is BuilderSet) {
      return IntensionalSetIntersection(first, second.intersection(other));
    } else {
      return IntensionalSetIntersection(second, first.intersection(other));
    }
  }

  @override
  BSSet operateIntensionalSetIntersectionBuilderSet(
          IntensionalSetIntersection first, BuilderSet second) =>
      _groupIntensional(first.first, first.second, second);

  @override
  BSSet operateIntensionalSetIntersectionEmptySet(
          IntensionalSetIntersection first, EmptySet second) =>
      emptySet;

  @override
  BSSet operateIntensionalSetIntersectionIntensionalSetIntersection(
          IntensionalSetIntersection first,
          IntensionalSetIntersection second) =>
      IntensionalSetIntersection(first, second);

  @override
  BSSet operateIntervalBuilderSet(Interval first, BuilderSet second) =>
      IntensionalSetIntersection(first, second);

  @override
  BSSet operateIntervalEmptySet(Interval first, EmptySet second) => second;

  @override
  BSSet operateIntervalIntensionalSetIntersection(
          Interval first, IntensionalSetIntersection second) =>
      _groupNotIntensional(second.first, second.second, first);

  @override
  BSSet operateIntervalInterval(Interval first, Interval second) {
    final _a = max(first.a, second.a);
    final _b = min(first.b, second.b);

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
  }

  @override
  BSSet operateRosterSetBuilderSet(RosterSet first, BuilderSet second) =>
      IntensionalSetIntersection(
          rosterSet(
              first.elements.where((element) => !second.belongs(element))),
          second);

  @override
  BSSet operateRosterSetEmptySet(RosterSet first, EmptySet second) => emptySet;

  @override
  BSSet operateRosterSetIntensionalSetIntersection(
          RosterSet first, IntensionalSetIntersection second) =>
      _groupNotIntensional(second.first, second.second, first);

  @override
  BSSet operateRosterSetInterval(RosterSet first, Interval second) =>
      rosterSet(first.elements.where((element) => second.belongs(element)));

  @override
  BSSet operateRosterSetRosterSet(RosterSet first, RosterSet second) =>
      rosterSet(first.elements.where((element) => second.belongs((element))));

  @override
  BSSet operateSetUnionBuilderSet(SetUnion first, BuilderSet second) =>
      IntensionalSetIntersection(first, second);

  @override
  BSSet operateSetUnionEmptySet(SetUnion first, EmptySet second) => emptySet;

  @override
  BSSet operateSetUnionIntensionalSetIntersection(
          SetUnion first, IntensionalSetIntersection second) =>
      _groupNotIntensional(second.first, second.second, first);

  @override
  BSSet operateSetUnionInterval(SetUnion first, Interval second) =>
      setUnion(first.subsets.map((e) => second.intersection(e)));

  @override
  BSSet operateSetUnionRosterSet(SetUnion first, RosterSet second) =>
      rosterSet(second.elements.where((element) => first.belongs(element)));

  @override
  BSSet operateSetUnionSetUnion(SetUnion first, SetUnion second) =>
      setUnion(second.subsets.map((e) => first.intersection(e)));
}
