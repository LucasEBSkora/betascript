import 'set.dart';
import '../function/functions.dart';
import 'visitor/set_visitor.dart';

const EmptySet emptySet = EmptySet._();

class EmptySet extends BSSet {
  const EmptySet._();

  BSSet complement() => BSSet.R;

  bool belongs(BSFunction x) => false;

  @override
  ReturnType accept<ReturnType>(SetVisitor visitor) =>
      visitor.visitEmptySet(this);
}
