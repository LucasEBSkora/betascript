import 'package:meta/meta.dart';

import 'empty_set.dart';
import 'interval.dart';
import '../βs_function/βs_calculus.dart';

import 'set_operation_tables/contains.dart';
import 'set_operation_tables/disjoined.dart';
import 'set_operation_tables/relative_complements.dart';
import 'set_operation_tables/union.dart';
import 'set_operation_tables/intersection.dart';

import '../utils/method_table.dart';

//class that represents a set in R
abstract class BSSet {
  static final MethodTable<BSSet, BSSet> _relativeComplements =
      defineRelativeComplementTable();
  static final MethodTable<bool, BSSet> _contains = defineContainsTable();

  static final ComutativeMethodTable<BSSet, BSSet> _unions = defineUnionTable();
  static final ComutativeMethodTable<BSSet, BSSet> _intersections =
      defineIntersectionTable();
  static final ComutativeMethodTable<bool, BSSet> _disjoined =
      defineDisjoinedTable();

  static const R =
      Interval(constants.negativeInfinity, constants.infinity, false, false);

  const BSSet();

  ///returns R\this (this')
  BSSet complement();

  bool belongs(BSFunction x);

  ///returns this\other (this without the elements in other)
  @nonVirtual
  BSSet relativeComplement(BSSet other) => (disjoined(other))
      ? this
      : (other.contains(this)
          ? emptySet
          : _relativeComplements.call(this, other));

  //Doesn't check for disjoint sets here because that would decrease performance instead of increasing it
  //(in some cases we can peform the union without checking for it, or checking would be done more than once)
  @nonVirtual
  BSSet union(BSSet other) => _unions.call(this, other);

  @nonVirtual
  BSSet intersection(BSSet other) =>
      (disjoined(other)) ? emptySet : _intersections.call(this, other);

  @nonVirtual
  bool contains(BSSet b) =>
      (this is EmptySet) ? (b is EmptySet) : _contains.call(this, b);

  @nonVirtual
  bool disjoined(BSSet b) =>
      (this is EmptySet || b is EmptySet) ? true : _disjoined.call(this, b);

  @override
  String toString() => "Subset of R";
}

class SetDefinitionError implements Exception {
  final String message;

  SetDefinitionError(this.message);

  @override
  String toString() => "Set definition error: $message";
}
