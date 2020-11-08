import 'dart:collection' show HashMap, SplayTreeSet;

import 'constant.dart';
import 'logic_expression.dart';
import '../sets/sets.dart';
import '../βs_function/βs_calculus.dart';

LogicExpression or(LogicExpression left, LogicExpression right) {
  // (1 || A) == 1, (0 || A) == A
  if (left is Constant) {
    return (left.value) ? left : right;
  }
  if (right is Constant) {
    return (right.value) ? right : left;
  }

  return Or(left, right);
}

class Or extends LogicExpression {
  final LogicExpression left;
  final LogicExpression right;

  const Or(this.left, this.right);

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
    return SplayTreeSet<String>.from(
        <String>{...left.parameters, ...right.parameters});
  }

  @override
  bool get foundEverySolution =>
      left.foundEverySolution && right.foundEverySolution;
}
