import 'BSSet.dart';

import '../BSFunction/BSCalculus.dart';

class DisjoinedSetUnion extends BSSet {
  final Set<BSSet> subsets;

  //TODO: check if it actually is disjoined
  DisjoinedSetUnion(Iterable<BSSet> subsets) : subsets = Set.from(subsets);


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
    bool contains(BSSet x) {
      // TODO: implement contains
      throw UnimplementedError();
    }
  
    @override
    BSSet intersection(BSSet x) {
      // TODO: implement intersection
      throw UnimplementedError();
    }
  
    @override
    BSSet relativeComplement(BSSet x) {
      // TODO: implement relativeComplement
      throw UnimplementedError();
    }
  
    @override
    BSSet union(BSSet x) {
    // TODO: implement union
    throw UnimplementedError();
  }

  @override
  bool disjoined(BSSet b) {
    // TODO: implement disjoined
    throw UnimplementedError();
  }

}