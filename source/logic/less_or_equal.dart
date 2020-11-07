import '../βs_function/βs_function.dart';
import 'comparison.dart';

class LessOrEqual extends Comparison {
  LessOrEqual(BSFunction left, BSFunction right) : super(left, right);

  @override
  bool compare(num _left, num _right) => _left <= _right;

  @override
  String get type => "<=";
}
