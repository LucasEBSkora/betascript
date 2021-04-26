import 'dart:collection' show SplayTreeSet;

import '../empty_set.dart';
import 'set_operation.dart';
import '../sets.dart';
import '../../function/functions.dart';
import '../../logic/logic.dart';

class RelativeComplement extends EmptyFilteringSetOperation<BSSet> {
  BSSet _throughDefinition(BSSet first, BSSet second) =>
      first.intersection(second.complement());

  BSSet _removeIteratively(BSSet first, List<BSSet> subsets) => subsets.fold(
      first, (previousValue, element) => first.relativeComplement(element));

  @override
  BSSet operateBuilderSetBuilderSet(BuilderSet first, BuilderSet second) =>
      builderSet(And(first.rule, Not(second.rule)));

  @override
  BSSet operateBuilderSetIntensionalSetIntersection(
      BuilderSet first, IntensionalSetIntersection second) {
    //tries to group the intensional part
    if (second.first is BuilderSet) {
      return _removeIteratively(first, [second.first, second.second]);
    } else {
      return _removeIteratively(first, [second.second, second.first]);
    }
  }

  @override
  BSSet operateBuilderSetInterval(BuilderSet first, Interval second) =>
      _throughDefinition(first, second);

  @override
  BSSet operateBuilderSetRosterSet(BuilderSet first, RosterSet second) =>
      _throughDefinition(first, second);

  @override
  BSSet operateBuilderSetSetUnion(BuilderSet first, SetUnion second) =>
      _throughDefinition(first, second);

  @override
  BSSet operateIntensionalSetIntersectionBuilderSet(
          IntensionalSetIntersection first, BuilderSet second) =>
      _throughDefinition(first, second);

  @override
  BSSet operateIntensionalSetIntersectionIntensionalSetIntersection(
          IntensionalSetIntersection first,
          IntensionalSetIntersection second) =>
      _removeIteratively(first, [second.first, second.second]);

  @override
  BSSet operateIntensionalSetIntersectionInterval(
          IntensionalSetIntersection first, Interval second) =>
      _throughDefinition(first, second);

  @override
  BSSet operateIntensionalSetIntersectionRosterSet(
          IntensionalSetIntersection first, RosterSet second) =>
      _throughDefinition(first, second);

  @override
  BSSet operateIntensionalSetIntersectionSetUnion(
          IntensionalSetIntersection first, SetUnion second) =>
      _removeIteratively(first, second.subsets);

  @override
  BSSet operateIntervalBuilderSet(Interval first, BuilderSet second) =>
      _throughDefinition(first, second);

  @override
  BSSet operateIntervalIntensionalSetIntersection(
          Interval first, IntensionalSetIntersection second) =>
      _throughDefinition(first, second);

  @override
  BSSet operateIntervalInterval(Interval first, Interval second) {
    if (first.contains(second).asBool()) {
      //second is fully contained in first
      return SetUnion([
        interval(first.a, second.a,
            leftClosed: first.leftClosed, rightClosed: !second.leftClosed),
        interval(second.b, first.b,
            leftClosed: !second.rightClosed, rightClosed: first.rightClosed)
      ]);
    }
    //left edge of second is in first
    if (first.belongs(second.a)) {
      return Interval(first.a, second.a, first.leftClosed, !second.leftClosed);
    }

    //right edge of second is in first: only other case
    // if (first.belongs(second.b))
    return Interval(second.b, first.b, !second.rightClosed, first.rightClosed);
  }

  @override
  BSSet operateIntervalRosterSet(Interval first, RosterSet second) {
    //Only elements which concern us are the ones contained in first
    final containedElements = second.elements.where(first.belongs);

    return SetUnion(<BSSet>[
      //See RosterSet.complement
      Interval(first.a, containedElements.first, first.leftClosed, false),
      for (int i = 0; i < containedElements.length; ++i)
        Interval.open(
            containedElements.elementAt(i - 1), containedElements.elementAt(i)),
      Interval(containedElements.last, first.a, false, first.rightClosed)
    ]);
  }

  @override
  BSSet operateIntervalSetUnion(Interval first, SetUnion second) =>
      _removeIteratively(first, second.subsets);

  SplayTreeSet<BSFunction> _removeWhereBelongs(
          SplayTreeSet<BSFunction> elements, BSSet second) =>
      SplayTreeSet<BSFunction>.from(
          elements.where((element) => !second.belongs(element)));

  @override
  BSSet operateRosterSetBuilderSet(RosterSet first, BuilderSet second) =>
      rosterSet(_removeWhereBelongs(first.elements, second));

  @override
  BSSet operateRosterSetIntensionalSetIntersection(
          RosterSet first, IntensionalSetIntersection second) =>
      rosterSet(_removeWhereBelongs(first.elements, second));

  @override
  BSSet operateRosterSetInterval(RosterSet first, Interval second) =>
      rosterSet(_removeWhereBelongs(first.elements, second));

  @override
  BSSet operateRosterSetRosterSet(RosterSet first, RosterSet second) =>
      rosterSet(first.elements
          .where((element) => !second.elements.contains(element)));

  @override
  BSSet operateRosterSetSetUnion(RosterSet first, SetUnion second) =>
      rosterSet(_removeWhereBelongs(first.elements, second));

  @override
  BSSet operateSetUnionBuilderSet(SetUnion first, BuilderSet second) =>
      _throughDefinition(first, second);

  @override
  BSSet operateSetUnionIntensionalSetIntersection(
          SetUnion first, IntensionalSetIntersection second) =>
      _throughDefinition(first, second);

  List<BSSet> _complementFromEvery(List<BSSet> subsets, BSSet other) =>
      subsets.map((e) => e.relativeComplement(other)).toList();

  @override
  BSSet operateSetUnionInterval(SetUnion first, Interval second) =>
      SetUnion(_complementFromEvery(first.subsets, second));

  @override
  BSSet operateSetUnionRosterSet(SetUnion first, RosterSet second) =>
      SetUnion(_complementFromEvery(first.subsets, second));

  @override
  BSSet operateSetUnionSetUnion(SetUnion first, SetUnion second) =>
      SetUnion(_complementFromEvery(first.subsets, second));

  @override
  BSSet onEmpty(BSSet first, BSSet second) =>
      (first == emptySet) ? emptySet : second;
}
