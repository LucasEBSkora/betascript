import 'set.dart';
import '../function/functions.dart';

const EmptySet emptySet = EmptySet._();

class EmptySet extends BSSet {
  const EmptySet._();

  BSSet complement() => BSSet.R;

  bool belongs(BSFunction x) => false;

  @override
  String toString() => "∅";
}
