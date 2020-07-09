import '../../Utils/MethodTable.dart';
import '../sets.dart';
import '../../BSFunction/BSCalculus.dart';

//Remember that if we get to this method we already know the sets aren't disjoined and that the second doesn't
//contain the first
MethodTable<BSSet, BSSet> defineRelativeComplementTable() {
  MethodTable<BSSet, BSSet> methods;

  methods.addMethod(Interval, Interval, (Interval first, Interval second) {
    if (first.contains(second)) //second is fully contained in first
      return DisjoinedSetUnion([
        Interval(first.a, second.a, first.leftClosed, !second.leftClosed),
        Interval(second.b, first.b, !second.rightClosed, first.rightClosed)
      ]);

    //left edge of second is in first
    if (first.belongs(second.a))
      return Interval(first.a, second.a, first.leftClosed, !second.leftClosed);

    //right edge of second is in first: only other case
    // if (first.belongs(second.b))
    return Interval(second.b, first.b, !second.rightClosed, first.rightClosed);
  });

  methods.addMethod(Interval, RosterSet, (Interval first, RosterSet second) {
    //Only elements which concern us are the ones contained in first
    List<BSFunction> containedElements =
        second.elements.where((element) => first.belongs(element));

    List<BSSet> complementSubsets = List();

    //See RosterSet.complement
    complementSubsets.add(
        Interval(first.a, containedElements.first, first.leftClosed, false));

    for (int i = 0; i < containedElements.length; ++i)
      complementSubsets.add(Interval.open(
          containedElements.elementAt(i - 1), containedElements.elementAt(i)));

    complementSubsets.add(
        Interval(containedElements.last, first.a, false, first.rightClosed));

    return DisjoinedSetUnion(complementSubsets);
  });

  methods.addMethodsInColumn(
      [Interval, RosterSet, BuilderSet],
      DisjoinedSetUnion,
      (BSSet first, DisjoinedSetUnion second) => second.subsets.fold(
          first, (previousValue, element) => first.relativeComplement(second)));

  methods.addMethodsInLine(
      RosterSet,
      [Interval, RosterSet, BuilderSet, DisjoinedSetUnion],
      (RosterSet first, BSSet second) => RosterSet(
          first.elements.where((element) => !second.belongs(element))));

  methods.addMethodsInLine(
      DisjoinedSetUnion,
      [Interval, RosterSet, BuilderSet, DisjoinedSetUnion],
      (DisjoinedSetUnion first, BSSet second) => DisjoinedSetUnion(
          first.subsets.map((e) => e.relativeComplement(second))));

  return methods;
}
