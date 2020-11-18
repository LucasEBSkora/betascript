import 'empty_set.dart';
import 'roster_set.dart';
import 'βs_set.dart';
import '../βs_function/βs_calculus.dart';

BSSet setUnion(Iterable<BSSet> subsets) {
  var _subsets = subsets.where((element) => !(element == emptySet)).toList();
  //Checks for things which can be completely simplified
  if (_subsets.isEmpty) return emptySet;
  if (_subsets.length == 1) return subsets.elementAt(0);

  //Checks if the elements are actually disjoined
  var i = 0;
  while (i < _subsets.length) {
    var j = i + 1;
    while (j < _subsets.length) {
      if (i != j && !_subsets[i].disjoined(_subsets[j]).asBool()) {
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
    var element = _subsets[i];
    if (element is SetUnion) {
      _subsets.removeAt(i);
      _subsets.insertAll(i, element.subsets);
    }
  }
  _subsets = _subsets.where((element) => !(element == emptySet)).toList();

  var rosterElements = <BSFunction>[];

  for (var i = 0; i < _subsets.length;) {
    var _set = _subsets[i];
    if (_set is RosterSet) {
      rosterElements.addAll(_set.elements);
      _subsets.removeAt(i);
    } else if (_set is EmptySet) {
      _subsets.removeAt(i);
    } else {
      ++i;
    }
  }

  if (rosterElements.isNotEmpty) _subsets.add(rosterSet(rosterElements));

  if (_subsets.isEmpty) return emptySet;
  if (_subsets.length == 1) return _subsets.elementAt(0);

  return SetUnion(_subsets);
}

///represents unions of sets, trying to have as little redundancy as possible
class SetUnion extends BSSet {
  final List<BSSet> subsets;

  const SetUnion(this.subsets);

  @override
  bool belongs(BSFunction x) {
    for (var i = 0; i < subsets.length; ++i) {
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
