
import 'BSFunction.dart';

enum ComparisonType {
  eq, //==
  lt, //<
  gt, //>
  le, //<=
  ge, //>=
  ne // =/=
  
}


///A class that represents an equation or inequality
class Comparison {
  final BSFunction left;
  final BSFunction right;
  final ComparisonType type;
  Comparison(this.left, this.right, this.type);
}