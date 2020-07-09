import 'BSSet.dart';

import '../BSFunction/BSCalculus.dart';
import 'EmptySet.dart';
import 'RosterSet.dart';

BSSet disjoinedSetUnion(Iterable<BSSet> subsets) {
  //Checks for things which can be completely simplified
  if (subsets.length == 0) return emptySet;
  if (subsets.length == 1) return subsets.elementAt(0);

  List<BSSet> _subsets =
      subsets.where((element) => !(element is EmptySet)).toList();

  //Checks if the elements are actually disjoined
  int i = 0;
  while (i < _subsets.length) {
    int j = i + 1;
    while (j < _subsets.length) {
      if (i != j && !_subsets[i].disjoined(_subsets[j])) {
        _subsets[i] = _subsets[i].union(_subsets[j]);
        _subsets.removeAt(j);
        j = i +
            1; //Goes back to checking from the beginning, since the new set united with the other might not be disjoint of other
      } else
        ++j;
    }
    ++i;
  }

  //If any of the subsets is itself a union of disjoint sets, removes that union and adds its elements to this one
  for (int i = 0; i < _subsets.length; ++i) {
    BSSet element = _subsets[i];
    if (element is DisjoinedSetUnion) {
      _subsets.removeAt(i);
      _subsets.insertAll(i, element.subsets);
    }
  }

  _subsets = _subsets.where((element) => !(element is EmptySet)).toList();

  List<BSFunction> rosterElements = List();

  for (int i = 0; i < _subsets.length;) {
    BSSet _set = _subsets[i];
    if (_set is RosterSet) {
      rosterElements.addAll(_set.elements);
      _subsets.removeAt(i);
    } else if (_set is EmptySet)
      _subsets.removeAt(i);
    else
      ++i;
  }

  if (rosterElements.isNotEmpty) _subsets.add(rosterSet(rosterElements));

  if (_subsets.length == 0) return emptySet;
  if (_subsets.length == 1) return _subsets.elementAt(0);

  return DisjoinedSetUnion(_subsets);
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

  @override
  String toString() => subsets.sublist(1).fold<String>(subsets[0].toString(),
      (previousValue, element) => previousValue + " ∪ $element");
}
