import 'comparison.dart';
import '../βs_function/βs_function.dart';

class NotEqual extends Comparison {
  NotEqual(BSFunction left, BSFunction right) : super(left, right);

  @override
  bool compare(num _left, num _right) => _left != _right;

  @override
  String get type => "=/=";
}
