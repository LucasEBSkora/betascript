import 'dart:collection' show SplayTreeSet;

import '../BSFunction/BSFunction.dart';

import 'BSSet.dart';
import 'sets.dart';

BSSet rosterSet(Iterable<BSFunction> elements) {
  return RosterSet(Set.from(elements));
}

//a class that represents an interval in R
class RosterSet extends BSSet {
  final SplayTreeSet<BSFunction> elements;

  RosterSet(SplayTreeSet<BSFunction> this.elements);

  @override
  bool belongs(BSFunction x) {
    // TODO: implement belongs
    throw UnimplementedError();
  }

  @override
  BSSet complement() {
    // TODO: implement complement
    throw UnimplementedError();
  }

  @override
  String toString() =>
      // TODO: implement toString
      throw UnimplementedError();
}
