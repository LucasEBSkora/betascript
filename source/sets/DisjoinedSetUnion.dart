import 'BSSet.dart';

import '../BSFunction/BSCalculus.dart';

BSSet disjoinedSetUnion(Iterable<BSSet> subsets) {
  return DisjoinedSetUnion(Set.from(subsets));
}

class DisjoinedSetUnion extends BSSet {
  final Set<BSSet> subsets;

  //TODO: check if it actually is disjoined
  DisjoinedSetUnion(Set<BSSet> this.subsets);

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
}
