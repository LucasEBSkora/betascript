import '../../Utils/MethodTable.dart';
import '../sets.dart';
import '../../BSFunction/BSCalculus.dart';

ComutativeMethodTable<BSSet, BSSet> defineIntersectionTable() {
  ComutativeMethodTable<BSSet, BSSet> methods;

  methods.addMethod(Interval, Interval, (Interval first, Interval second) {
    BSFunction _a = BSFunction.max(first.a, second.a);
    BSFunction _b = BSFunction.min(first.b, second.b);

    bool _leftClosed;
    if (first.a == second.a)
      _leftClosed = first.leftClosed && second.leftClosed;
    else
      _leftClosed = first.a > second.a ? first.leftClosed : second.leftClosed;

    bool _rightClosed;
    if (first.b == second.b)
      _rightClosed = first.rightClosed && second.rightClosed;
    else
      _rightClosed =
          first.b < second.b ? first.rightClosed : second.rightClosed;

    return interval(_a, _b, leftClosed: _leftClosed, rightClosed: _rightClosed);
  });

  methods.addMethod(
      Interval,
      RosterSet,
      (Interval first, RosterSet second) => disjoinedSetUnion([
            first,
            RosterSet(
                second.elements.where((element) => !first.belongs(element)))
          ]));

  methods.addMethodsInColumn(
      //Depends on the simplifications to remove empty sets that remain
      [Interval, RosterSet, BuilderSet],
      DisjoinedSetUnion,
      (Interval first, DisjoinedSetUnion second) =>
          disjoinedSetUnion(second.subsets.map((e) => first.intersection(e))));

  methods.addMethod(DisjoinedSetUnion, DisjoinedSetUnion,
      (DisjoinedSetUnion first, DisjoinedSetUnion second) {
    List<BSSet> _new = List();
    //computes the union of the intersections of second
    //with each set in first
    first.subsets.forEach((element) => _new.add(second.intersection(element)));

    return disjoinedSetUnion(_new);
  });

  
  methods.addMethod(
      RosterSet,
      RosterSet,
      (RosterSet first, RosterSet second) => RosterSet(
          first.elements.where((element) => second.belongs((element)))));

  return methods;
}
