class Pair<F, S> {
  F first;
  S second;

  Pair(F this.first, S this.second);

  @override
  String toString() {
    return '(' + first.toString() + ' , ' + second.toString() + ')';
  }
}