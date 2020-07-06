import 'Interval.dart';
import '../BSFunction/BSCalculus.dart';

//class that represents a set in R
abstract class BSSet {

  static const R = Interval(constants.negativeInfinity, constants.infinity, false, false);

  const BSSet();

  BSSet union(BSSet other);
  BSSet intersection(BSSet other);

  ///returns R\this (this')
  BSSet complement();

  ///returns this\other (this without the elements in other)
  BSSet relativeComplement(BSSet other);

  bool belongs(BSFunction x);
  bool contains(BSSet b);
  bool disjoined(BSSet b);
  @override
  String toString() => "Subset of R";
}