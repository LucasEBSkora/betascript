import 'dart:collection';

import '../../Utils/MethodTable.dart';
import '../sets.dart';
import '../../BSFunction/BSCalculus.dart';

//If we get to this function, we already now the sets are not disjoined
ComutativeMethodTable<BSSet, BSSet> defineUnionTable() {
  ComutativeMethodTable<BSSet, BSSet> methods = ComutativeMethodTable();

  methods.addMethod(Interval, Interval, (Interval first, Interval second) {
    //calls constructor directly instead of builder function because we already know the sets are disjoint
    if (first.disjoined(second)) return DisjoinedSetUnion([first, second]);
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

  methods
      .addMethodsInColumn([Interval, RosterSet, BuilderSet], DisjoinedSetUnion,
          (BSSet first, DisjoinedSetUnion second) {
    List<BSSet> _new = List.from(second.subsets);
    _new.add(first);
    //Delegates to the DisjoinedSetUnion factory function for simplifications
    return disjoinedSetUnion(_new);
  });

  methods.addMethod(Interval, RosterSet, (Interval first, RosterSet second) {
    //checks if we can "close" an interval edge with the elements of the roster set.
    first = interval(first.a, first.b,
        leftClosed: first.leftClosed || second.belongs(first.a),
        rightClosed: first.rightClosed || second.belongs(first.b));

    return disjoinedSetUnion([
      first,
      rosterSet(second.elements.where((element) => !first.belongs(element)))
    ]);
  });

  //Uses the native set implementation to filter out repeated elements
  methods.addMethod(RosterSet, RosterSet, (RosterSet first, RosterSet second) {
    SplayTreeSet<BSFunction> _new = SplayTreeSet.from(first.elements);
    _new.addAll(second.elements);
    RosterSet(_new);
  });

  methods.addMethod(DisjoinedSetUnion, DisjoinedSetUnion,
      (DisjoinedSetUnion first, DisjoinedSetUnion second) {
    List<BSSet> _new = List.from(first.subsets);
    _new.addAll(second.subsets);
    //Delegates to the DisjoinedSetUnion factory function for simplifications
    return disjoinedSetUnion(_new);
  });

  return methods;
}
