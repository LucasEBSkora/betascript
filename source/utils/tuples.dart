class Pair<F, S> {
  F first;
  S second;

  Pair(this.first, this.second);

  @override
  String toString() => '($first , $second)';
}

// class Trio<F, S, T> {
//   F first;
//   S second;
//   T third;

//   Trio(this.first, this.second, this.third);

//   @override
//   String toString() => '($first , $second, $third)';
// }
