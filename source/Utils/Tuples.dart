class Pair<F, S> {
  F first;
  S second;

  Pair(F this.first, S this.second);

  @override
  String toString() => '($first , $second)';
}

class Trio<F, S, T> {
  F first;
  S second;
  T third;

  Trio(F this.first, S this.second, T this.third);

  @override
  String toString() => '($first , $second, $third)';
}