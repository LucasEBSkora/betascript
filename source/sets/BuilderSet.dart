import '../BSFunction/BSFunction.dart';
import 'BSSet.dart';

import '../BSFunction/Comparison.dart';

BSSet builderSet(Iterable<Comparison> rules) {
  return BuilderSet(Set.from(rules));
}

class BuilderSet extends BSSet {
  final Set<Comparison> rules;

  BuilderSet(this.rules);

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
