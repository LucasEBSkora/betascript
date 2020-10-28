import '../BSFunction/BSFunction.dart';
import 'Comparison.dart';

class GreaterOrEqual extends Comparison {
  GreaterOrEqual(BSFunction left, BSFunction right) : super(left, right);

  @override
  bool compare(num _left, num _right) => _left >= _right;

  @override
  String get type => ">=";
}
