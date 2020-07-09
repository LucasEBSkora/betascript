import 'BSSet.dart';

import '../BSFunction/BSCalculus.dart';
import 'EmptySet.dart';

BSSet disjoinedSetUnion(List<BSSet> subsets) {
  //Checks for things which can be completely simplified
  if (subsets.length == 0) return emptySet;
  if (subsets.length == 1) return subsets.elementAt(0);

  //Checks if the elements are actually disjoined
  int i = 0;
  while (i < subsets.length) {
    int j = i + 1;
    while (j < subsets.length) {
      if (!subsets[i].disjoined(subsets[j])) {
        subsets[i] = subsets[i].union(subsets[j]);
        subsets.removeAt(j);
      } else
        ++j;
    }
  }

  //If any of the subsets is itself a union of disjoint sets, removes that union and adds its elements to this one
  for (int i = 0; i < subsets.length; ++i) {
    BSSet element = subsets[i];
    if (element is DisjoinedSetUnion) {
      subsets.removeAt(i);
      subsets.insertAll(i, element.subsets);
    }
  }

  for (int i = 0; i < subsets.length; ++i)
    for (int j = i + 1; j < subsets.length; ++j) {}
  return DisjoinedSetUnion(subsets);
}

class DisjoinedSetUnion extends BSSet {
  final List<BSSet> subsets;

  DisjoinedSetUnion(List<BSSet> this.subsets);

  @override
  bool belongs(BSFunction x) {
    for (int i = 0; i < subsets.length; ++i) {
      if (subsets.elementAt(i).belongs(x)) return true;
    }
    return false;
  }

  @override
  BSSet complement() => subsets.fold<BSSet>(
      BSSet.R, (value, element) => value.relativeComplement(element));
}
