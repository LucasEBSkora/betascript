import 'BSSet.dart';

import '../BSFunction/BSCalculus.dart';

const EmptySet emptySet = EmptySet._();

class EmptySet extends BSSet {
  const EmptySet._();

  BSSet complement() => BSSet.R;

  bool belongs(BSFunction x) => false;

  @override
  String toString() => "∅";
}
