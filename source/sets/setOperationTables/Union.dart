import '../../Utils/MethodTable.dart';
import '../sets.dart';
import '../../BSFunction/BSCalculus.dart';

ComutativeMethodTable<BSSet, BSSet> defineUnionTable() {
  ComutativeMethodTable<BSSet, BSSet> methods;

  methods.addMethod(Interval, Interval, (Interval first, Interval second) {
    BSFunction _a = BSFunction.min(first.a, second.a);
    BSFunction _b = BSFunction.max(first.b, second.b);

    bool _leftClosed;
    if (first.a == second.a)
      _leftClosed = first.leftClosed || second.leftClosed;
    else
      _leftClosed = first.a < second.a ? first.leftClosed : second.leftClosed;

    bool _rightClosed;
    if (first.b == second.b)
      _rightClosed = first.rightClosed || second.rightClosed;
    else
      _rightClosed =
          first.b > second.b ? first.rightClosed : second.rightClosed;

    return interval(_a, _b, leftClosed: _leftClosed, rightClosed: _rightClosed);
  });

  methods.addMethod(Interval, DisjoinedSetUnion,
      (Interval first, DisjoinedSetUnion second) {
    Set<BSSet> _new = Set.from(second.subsets);
    _new.add(first);
    return DisjoinedSetUnion(_new);
  });

  methods.addMethod(
      Interval,
      RosterSet,
      (Interval first, RosterSet second) => disjoinedSetUnion([
            first,
            RosterSet(
                second.elements.where((element) => !first.belongs(element)))
          ]));

  return methods;
}
