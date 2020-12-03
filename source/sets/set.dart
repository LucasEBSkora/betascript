import 'package:meta/meta.dart';

import 'empty_set.dart';
import 'interval.dart';
import 'set_operation_tables/contains.dart';
import 'set_operation_tables/disjoined.dart';
import 'set_operation_tables/intersection.dart';
import 'set_operation_tables/relative_complements.dart';
import 'set_operation_tables/union.dart';
import '../utils/method_table.dart';
import '../utils/three_valued_logic.dart';
import '../function/functions.dart';

//class that represents a set in R
abstract class BSSet {
  static final MethodTable<BSSet, BSSet> _relativeComplements =
      defineRelativeComplementTable();
  static final MethodTable<BSLogical, BSSet> _contains = defineContainsTable();

  static final ComutativeMethodTable<BSSet, BSSet> _unions = defineUnionTable();
  static final ComutativeMethodTable<BSSet, BSSet> _intersections =
      defineIntersectionTable();
  static final ComutativeMethodTable<BSLogical, BSSet> _disjoined =
      defineDisjoinedTable();

  static const R =
      Interval(Constants.negativeInfinity, Constants.infinity, false, false);

  const BSSet();

  ///R\this (this')
  BSSet complement();

  bool belongs(BSFunction x);

  ///returns this\other (this without the elements in other)
  @nonVirtual
  BSSet relativeComplement(BSSet other) => (disjoined(other).asBool())
      ? this
      : (other.contains(this).asBool()
          ? emptySet
          : _relativeComplements.call(this, other));

  //Doesn't check for disjoint sets here because that would decrease performance instead of increasing it
  //(in some cases we can peform the union without checking for it, or checking would be done more than once)
  @nonVirtual
  BSSet union(BSSet other) => _unions.call(this, other);

  @nonVirtual
  BSSet intersection(BSSet other) =>
      (disjoined(other).asBool()) ? emptySet : _intersections.call(this, other);

  @nonVirtual
  BSLogical contains(BSSet b) =>
      (this is EmptySet) ? (b is EmptySet) : _contains.call(this, b);

  @nonVirtual
  BSLogical disjoined(BSSet b) =>
      (this is EmptySet || b is EmptySet) ? true : _disjoined.call(this, b);

  @override
  String toString() => "Subset of R";
}

class SetDefinitionError implements Exception {
  final String message;

  const SetDefinitionError(this.message);

  @override
  String toString() => "Set definition error: $message";
}
