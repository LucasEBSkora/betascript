import 'package:meta/meta.dart';

import 'EmptySet.dart';
import 'Interval.dart';
import '../BSFunction/BSCalculus.dart';

import 'setOperationTables/Contains.dart';
import 'setOperationTables/Disjoined.dart';
import 'setOperationTables/RelativeComplements.dart';
import 'setOperationTables/Union.dart';
import 'setOperationTables/intersection.dart';

import '../Utils/MethodTable.dart';

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
