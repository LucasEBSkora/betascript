import 'dart:collection' show HashMap, SplayTreeSet;
import '../βs_function/βs_calculus.dart';
import '../sets/sets.dart';
import 'constant.dart';
import 'logic_expression.dart';

LogicExpression or(LogicExpression left, LogicExpression right) {
  // (1 || A) == 1, (0 || A) == A
  if (left is Constant) {
    if (left.value) {
      return left;
    } else
      return right;
  }
  if (right is Constant) {
    if (right.value) {
      return right;
    } else
      return left;
  }

  return Or(left, right);
}

class Or extends LogicExpression {
  final LogicExpression left;
  final LogicExpression right;

  Or(this.left, this.right);

  bool get alwaysTrue => left.alwaysTrue || right.alwaysTrue;

  bool get alwaysFalse => left.alwaysFalse || right.alwaysFalse;

  bool isSolution(HashMap<String, BSFunction> p) =>
      left.isSolution(p) || right.isSolution(p);

  bool containsSolution(BSSet s) =>
      left.containsSolution(s) || right.containsSolution(s);

  bool everyElementIsSolution(BSSet s) =>
      left.everyElementIsSolution(s) || right.everyElementIsSolution(s);

  BSSet get solution => left.solution.union(right.solution);

  @override
  String toString() => "($left) or ($right)";

  @override
  SplayTreeSet<String> get parameters {
    var params = left.parameters;
    params.addAll(right.parameters);
    return params;
  }

  @override
  bool get foundEverySolution =>
      left.foundEverySolution && right.foundEverySolution;
}
