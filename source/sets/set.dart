import 'package:meta/meta.dart';

import 'empty_set.dart';
import 'interval.dart';
import 'set_operations/contains.dart';
import 'set_operations/disjoined.dart';
import 'set_operations/intersection.dart';
import 'set_operations/relative_complements.dart';
import 'set_operations/union.dart';
import '../utils/three_valued_logic.dart';
import '../function/functions.dart';
import 'visitor/plain_set_stringifier.dart';
import 'visitor/set_visitor.dart';

//TODO: Propagate Intensionality properly

//class that represents a set in R
abstract class BSSet {
  static final _union = Union();
  static final _intersection = Intersection();
  static final _relativeComplement = RelativeComplement();
  static final _disjoined = Disjoined();
  static final _contains = Contains();

  static const R =
      Interval(Constants.negativeInfinity, Constants.infinity, false, false);

  const BSSet();

  ///R\this (this')
  BSSet complement();

  bool belongs(BSFunction x);
  
  //TODO: let SetOperation decide how to deal with empty sets

  ///returns this\other (this without the elements in other)
  @nonVirtual
  BSSet relativeComplement(BSSet other) => (disjoined(other).asBool())
      ? this
      : (other.contains(this).asBool()
          ? emptySet
          : _relativeComplement(this, other));

  //Doesn't check for disjoint sets here because that would decrease performance instead of increasing it
  //(in some cases we can peform the union without checking for it, or checking would be done more than once)
  @nonVirtual
  BSSet union(BSSet other) => _union(this, other);

  @nonVirtual
  BSSet intersection(BSSet other) =>
      (disjoined(other).asBool()) ? emptySet : _intersection(this, other);

  @nonVirtual
  BSLogical contains(BSSet b) =>
      (this is EmptySet) ? (b is EmptySet) : _contains.call(this, b);

  @nonVirtual
  BSLogical disjoined(BSSet b) =>
      (this is EmptySet || b is EmptySet) ? true : _disjoined.call(this, b);

  ReturnType accept<ReturnType>(SetVisitor visitor);

  @override
  @nonVirtual
  String toString() => accept(PlainSetStringifier());
}

class SetDefinitionError implements Exception {
  final String message;

  const SetDefinitionError(this.message);

  @override
  String toString() => "Set definition error: $message";
}
