import 'package:meta/meta.dart';
import '../../utils/method_table.dart';
import '../set.dart';
import '../builder_set.dart';
import '../empty_set.dart';
import '../intensional_set_intersection.dart';
import '../interval.dart';
import '../roster_set.dart';
import '../set_union.dart';

abstract class SetOperation<ReturnType> {
  final MethodTable _methodTable = MethodTable<ReturnType, BSSet>();

  ReturnType call(BSSet first, BSSet second) => _methodTable(first, second);

  SetOperation() {
    _methodTable.addMethod(BuilderSet, BuilderSet, operateBuilderSetBuilderSet);
    _methodTable.addMethod(BuilderSet, EmptySet, operateBuilderSetEmptySet);
    _methodTable.addMethod(BuilderSet, IntensionalSetIntersection,
        operateBuilderSetIntensionalSetIntersection);
    _methodTable.addMethod(BuilderSet, Interval, operateBuilderSetInterval);
    _methodTable.addMethod(BuilderSet, RosterSet, operateBuilderSetRosterSet);
    _methodTable.addMethod(BuilderSet, SetUnion, operateBuilderSetSetUnion);
    _methodTable.addMethod(EmptySet, BuilderSet, operateEmptySetBuilderSet);
    _methodTable.addMethod(EmptySet, EmptySet, operateEmptySetEmptySet);
    _methodTable.addMethod(EmptySet, IntensionalSetIntersection,
        operateEmptySetIntensionalSetIntersection);
    _methodTable.addMethod(EmptySet, Interval, operateEmptySetInterval);
    _methodTable.addMethod(EmptySet, RosterSet, operateEmptySetRosterSet);
    _methodTable.addMethod(EmptySet, SetUnion, operateEmptySetSetUnion);
    _methodTable.addMethod(IntensionalSetIntersection, BuilderSet,
        operateIntensionalSetIntersectionBuilderSet);
    _methodTable.addMethod(IntensionalSetIntersection, EmptySet,
        operateIntensionalSetIntersectionEmptySet);
    _methodTable.addMethod(
        IntensionalSetIntersection,
        IntensionalSetIntersection,
        operateIntensionalSetIntersectionIntensionalSetIntersection);
    _methodTable.addMethod(IntensionalSetIntersection, Interval,
        operateIntensionalSetIntersectionInterval);
    _methodTable.addMethod(IntensionalSetIntersection, RosterSet,
        operateIntensionalSetIntersectionRosterSet);
    _methodTable.addMethod(IntensionalSetIntersection, SetUnion,
        operateIntensionalSetIntersectionSetUnion);
    _methodTable.addMethod(Interval, BuilderSet, operateIntervalBuilderSet);
    _methodTable.addMethod(Interval, EmptySet, operateIntervalEmptySet);
    _methodTable.addMethod(Interval, IntensionalSetIntersection,
        operateIntervalIntensionalSetIntersection);
    _methodTable.addMethod(Interval, Interval, operateIntervalInterval);
    _methodTable.addMethod(Interval, RosterSet, operateIntervalRosterSet);
    _methodTable.addMethod(Interval, SetUnion, operateIntervalSetUnion);
    _methodTable.addMethod(RosterSet, BuilderSet, operateRosterSetBuilderSet);
    _methodTable.addMethod(RosterSet, EmptySet, operateRosterSetEmptySet);
    _methodTable.addMethod(RosterSet, IntensionalSetIntersection,
        operateRosterSetIntensionalSetIntersection);
    _methodTable.addMethod(RosterSet, Interval, operateRosterSetInterval);
    _methodTable.addMethod(RosterSet, RosterSet, operateRosterSetRosterSet);
    _methodTable.addMethod(RosterSet, SetUnion, operateRosterSetSetUnion);
    _methodTable.addMethod(SetUnion, BuilderSet, operateSetUnionBuilderSet);
    _methodTable.addMethod(SetUnion, EmptySet, operateSetUnionEmptySet);
    _methodTable.addMethod(SetUnion, IntensionalSetIntersection,
        operateSetUnionIntensionalSetIntersection);
    _methodTable.addMethod(SetUnion, Interval, operateSetUnionInterval);
    _methodTable.addMethod(SetUnion, RosterSet, operateSetUnionRosterSet);
    _methodTable.addMethod(SetUnion, SetUnion, operateSetUnionSetUnion);
  }

  @visibleForOverriding
  ReturnType operateBuilderSetBuilderSet(BuilderSet first, BuilderSet second);

  @visibleForOverriding
  ReturnType operateBuilderSetEmptySet(BuilderSet first, EmptySet second);

  @visibleForOverriding
  ReturnType operateBuilderSetIntensionalSetIntersection(
      BuilderSet first, IntensionalSetIntersection second);

  @visibleForOverriding
  ReturnType operateBuilderSetInterval(BuilderSet first, Interval second);

  @visibleForOverriding
  ReturnType operateBuilderSetRosterSet(BuilderSet first, RosterSet second);

  @visibleForOverriding
  ReturnType operateBuilderSetSetUnion(BuilderSet first, SetUnion second);

  @visibleForOverriding
  ReturnType operateEmptySetBuilderSet(EmptySet first, BuilderSet second);

  @visibleForOverriding
  ReturnType operateEmptySetEmptySet(EmptySet first, EmptySet second);

  @visibleForOverriding
  ReturnType operateEmptySetIntensionalSetIntersection(
      EmptySet first, IntensionalSetIntersection second);

  @visibleForOverriding
  ReturnType operateEmptySetInterval(EmptySet first, Interval second);

  @visibleForOverriding
  ReturnType operateEmptySetRosterSet(EmptySet first, RosterSet second);

  @visibleForOverriding
  ReturnType operateEmptySetSetUnion(EmptySet first, SetUnion second);

  @visibleForOverriding
  ReturnType operateIntensionalSetIntersectionBuilderSet(
      IntensionalSetIntersection first, BuilderSet second);

  @visibleForOverriding
  ReturnType operateIntensionalSetIntersectionEmptySet(
      IntensionalSetIntersection first, EmptySet second);

  @visibleForOverriding
  ReturnType operateIntensionalSetIntersectionIntensionalSetIntersection(
      IntensionalSetIntersection first, IntensionalSetIntersection second);

  @visibleForOverriding
  ReturnType operateIntensionalSetIntersectionInterval(
      IntensionalSetIntersection first, Interval second);

  @visibleForOverriding
  ReturnType operateIntensionalSetIntersectionRosterSet(
      IntensionalSetIntersection first, RosterSet second);

  @visibleForOverriding
  ReturnType operateIntensionalSetIntersectionSetUnion(
      IntensionalSetIntersection first, SetUnion second);

  @visibleForOverriding
  ReturnType operateIntervalBuilderSet(Interval first, BuilderSet second);

  @visibleForOverriding
  ReturnType operateIntervalEmptySet(Interval first, EmptySet second);

  @visibleForOverriding
  ReturnType operateIntervalIntensionalSetIntersection(
      Interval first, IntensionalSetIntersection second);

  @visibleForOverriding
  ReturnType operateIntervalInterval(Interval first, Interval second);

  @visibleForOverriding
  ReturnType operateIntervalRosterSet(Interval first, RosterSet second);

  @visibleForOverriding
  ReturnType operateIntervalSetUnion(Interval first, SetUnion second);

  @visibleForOverriding
  ReturnType operateRosterSetBuilderSet(RosterSet first, BuilderSet second);

  @visibleForOverriding
  ReturnType operateRosterSetEmptySet(RosterSet first, EmptySet second);

  @visibleForOverriding
  ReturnType operateRosterSetIntensionalSetIntersection(
      RosterSet first, IntensionalSetIntersection second);

  @visibleForOverriding
  ReturnType operateRosterSetInterval(RosterSet first, Interval second);

  @visibleForOverriding
  ReturnType operateRosterSetRosterSet(RosterSet first, RosterSet second);

  @visibleForOverriding
  ReturnType operateRosterSetSetUnion(RosterSet first, SetUnion second);

  @visibleForOverriding
  ReturnType operateSetUnionBuilderSet(SetUnion first, BuilderSet second);

  @visibleForOverriding
  ReturnType operateSetUnionEmptySet(SetUnion first, EmptySet second);

  @visibleForOverriding
  ReturnType operateSetUnionIntensionalSetIntersection(
      SetUnion first, IntensionalSetIntersection second);

  @visibleForOverriding
  ReturnType operateSetUnionInterval(SetUnion first, Interval second);

  @visibleForOverriding
  ReturnType operateSetUnionRosterSet(SetUnion first, RosterSet second);

  @visibleForOverriding
  ReturnType operateSetUnionSetUnion(SetUnion first, SetUnion second);
}

abstract class ComutativeSetOperation<ReturnType>
    extends SetOperation<ReturnType> {
  ComutativeSetOperation() : super();
  @override
  @nonVirtual
  ReturnType operateBuilderSetEmptySet(BuilderSet first, EmptySet second) =>
      operateEmptySetBuilderSet(second, first);

  @override
  @nonVirtual
  ReturnType operateBuilderSetIntensionalSetIntersection(
          BuilderSet first, IntensionalSetIntersection second) =>
      operateIntensionalSetIntersectionBuilderSet(second, first);

  @override
  @nonVirtual
  ReturnType operateBuilderSetInterval(BuilderSet first, Interval second) =>
      operateIntervalBuilderSet(second, first);

  @override
  @nonVirtual
  ReturnType operateBuilderSetRosterSet(BuilderSet first, RosterSet second) =>
      operateRosterSetBuilderSet(second, first);

  @override
  @nonVirtual
  ReturnType operateBuilderSetSetUnion(BuilderSet first, SetUnion second) =>
      operateSetUnionBuilderSet(second, first);

  @override
  @nonVirtual
  ReturnType operateEmptySetIntensionalSetIntersection(
          EmptySet first, IntensionalSetIntersection second) =>
      operateIntensionalSetIntersectionEmptySet(second, first);

  @override
  @nonVirtual
  ReturnType operateEmptySetInterval(EmptySet first, Interval second) =>
      operateIntervalEmptySet(second, first);

  @override
  @nonVirtual
  ReturnType operateEmptySetRosterSet(EmptySet first, RosterSet second) =>
      operateRosterSetEmptySet(second, first);

  @override
  @nonVirtual
  ReturnType operateEmptySetSetUnion(EmptySet first, SetUnion second) =>
      operateSetUnionEmptySet(second, first);

  @override
  @nonVirtual
  ReturnType operateIntensionalSetIntersectionInterval(
          IntensionalSetIntersection first, Interval second) =>
      operateIntervalIntensionalSetIntersection(second, first);

  @override
  @nonVirtual
  ReturnType operateIntensionalSetIntersectionRosterSet(
          IntensionalSetIntersection first, RosterSet second) =>
      operateRosterSetIntensionalSetIntersection(second, first);

  @override
  @nonVirtual
  ReturnType operateIntensionalSetIntersectionSetUnion(
          IntensionalSetIntersection first, SetUnion second) =>
      operateSetUnionIntensionalSetIntersection(second, first);

  @override
  @nonVirtual
  ReturnType operateIntervalRosterSet(Interval first, RosterSet second) =>
      operateRosterSetInterval(second, first);

  @override
  @nonVirtual
  ReturnType operateIntervalSetUnion(Interval first, SetUnion second) =>
      operateSetUnionInterval(second, first);

  @override
  @nonVirtual
  ReturnType operateRosterSetSetUnion(RosterSet first, SetUnion second) =>
      operateSetUnionRosterSet(second, first);
}
