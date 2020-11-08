import 'dart:collection' show HashMap, SplayTreeSet;

import 'constant.dart';
import 'logic_expression.dart';
import '../sets/sets.dart';
import '../βs_function/βs_calculus.dart';

LogicExpression and(LogicExpression left, LogicExpression right) {
  // (1 && A) == A, (0 && A) == 0
  if (left is Constant) {
    return (left.value) ? right : left;
  }
  if (right is Constant) {
    return (right.value) ? left : right;
  }

  return And(left, right);
}

class And extends LogicExpression {
  final LogicExpression left;
  final LogicExpression right;

  And(this.left, this.right);

  bool get alwaysTrue => left.alwaysTrue && right.alwaysTrue;

  bool get alwaysFalse => left.alwaysFalse && right.alwaysFalse;

  bool isSolution(HashMap<String, BSFunction> p) =>
      left.isSolution(p) && right.isSolution(p);

  bool containsSolution(BSSet s) =>
      left.containsSolution(s) && right.containsSolution(s);

  bool everyElementIsSolution(BSSet s) =>
      left.everyElementIsSolution(s) && right.everyElementIsSolution(s);

  BSSet get solution => left.solution.intersection(right.solution);

  @override
  String toString() => "($left) and ($right)";

  @override
  SplayTreeSet<String> get parameters {
    return SplayTreeSet<String>.from(
        <String>{...left.parameters, ...right.parameters});
  }

  @override
  bool get foundEverySolution =>
      left.foundEverySolution && right.foundEverySolution;
}
