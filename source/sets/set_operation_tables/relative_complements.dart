import '../../utils/method_table.dart';
import '../sets.dart';
import '../../βs_function/βs_calculus.dart';

//Remember that if we get to this method we already know the sets aren't disjoined and that the second doesn't
//contain the first
MethodTable<BSSet, BSSet> defineRelativeComplementTable() {
  MethodTable<BSSet, BSSet> methods = MethodTable();

  methods.addMethod(Interval, Interval, (Interval first, Interval second) {
    if (first.contains(second)) //second is fully contained in first
      return SetUnion([
        interval(first.a, second.a,
            leftClosed: first.leftClosed, rightClosed: !second.leftClosed),
        interval(second.b, first.b,
            leftClosed: !second.rightClosed, rightClosed: first.rightClosed)
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

    return SetUnion(complementSubsets);
  });

  methods.addMethodsInColumn(
      [Interval, IntensionalSetIntersection],
      SetUnion,
      (BSSet first, SetUnion second) => second.subsets.fold(
          first, (previousValue, element) => first.relativeComplement(second)));

  methods.addMethodsInLine(
      RosterSet,
      [Interval, RosterSet, BuilderSet, SetUnion, IntensionalSetIntersection],
      (RosterSet first, BSSet second) => RosterSet(
          first.elements.where((element) => !second.belongs(element))));

  methods.addMethodsInLine(
      SetUnion,
      [Interval, RosterSet, SetUnion],
      (SetUnion first, BSSet second) =>
          SetUnion(first.subsets.map((e) => e.relativeComplement(second))));

  //A\B = A ∩ (R\B)
  methods.addMethodsInColumn(
      [Interval, BuilderSet, IntensionalSetIntersection, SetUnion],
      BuilderSet,
      (BSSet first, BuilderSet second) =>
          first.intersection(second.complement()));

  methods.addMethodsInColumn(
      [Interval, BuilderSet, IntensionalSetIntersection, SetUnion],
      IntensionalSetIntersection,
      (BSSet first, IntensionalSetIntersection second) {
    //tries to simplifies the non-intensional part
    if (second.first is BuilderSet)
      return first
          .relativeComplement(second.second)
          .relativeComplement(second.first);
    if (second.second is BuilderSet)
      return first
          .relativeComplement(second.first)
          .relativeComplement(second.second);
  });

  methods.addMethodsInLine(
      BuilderSet,
      [Interval, RosterSet, SetUnion],
      (BuilderSet first, BSSet second) =>
          first.intersection(second.complement()));

  methods.addMethodsInLine(
      IntensionalSetIntersection,
      [Interval, RosterSet],
      (IntensionalSetIntersection first, BSSet second) =>
          first.intersection(second.complement()));

  return methods;
}
