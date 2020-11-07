import 'comparison.dart';
import '../βs_function/βs_function.dart';

class LessThan extends Comparison {
  LessThan(BSFunction left, BSFunction right) : super(left, right);

  @override
  bool compare(num _left, num _right) => _left < _right;

  @override
  String get type => "<";
}
