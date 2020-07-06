import 'BSSet.dart';

import '../BSFunction/BSCalculus.dart';

const EmptySet emptySet = EmptySet._();

class EmptySet extends BSSet {
  const EmptySet._();

  BSSet union(BSSet other) => other;
  BSSet intersection(BSSet other) => this;

  BSSet complement() => BSSet.R;

  BSSet relativeComplement(BSSet other) => this;

  bool belongs(BSFunction x) => false;
  bool contains(BSSet b) => false;
  bool disjoined(BSSet b) => true;

  @override
  String toString() => "∅";
}
