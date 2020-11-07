import 'βs_set.dart';

import '../βs_function/βs_calculus.dart';

const EmptySet emptySet = EmptySet._();

class EmptySet extends BSSet {
  const EmptySet._();

  BSSet complement() => BSSet.R;

  bool belongs(BSFunction x) => false;

  @override
  String toString() => "∅";

  @override
  bool operator ==(other) => other is EmptySet;
}
