import 'dart:collection' show HashMap, SplayTreeSet;

import 'constant.dart';
import 'logic_expression.dart';
import '../sets/sets.dart';
import '../utils/three_valued_logic.dart';
import '../function/functions.dart';

LogicExpression or(LogicExpression left, LogicExpression right) {
  // (1 || A) == 1, (0 || A) == A
  if (left is Constant) {
    if (left.value == bsUnknown) return left;
    return (left.value.asBool()) ? left : right;
  }
  if (right is Constant) {
    if (right.value == bsUnknown) return right;
    return (right.value.asBool()) ? right : left;
  }

  return Or(left, right);
}

class Or extends LogicExpression {
  final LogicExpression left;
  final LogicExpression right;

  const Or(this.left, this.right);

  BSLogical get alwaysTrue => left.alwaysTrue | right.alwaysTrue;

  BSLogical get alwaysFalse => left.alwaysFalse & right.alwaysFalse;

  BSLogical isSolution(HashMap<String, BSFunction> p) =>
      left.isSolution(p) | right.isSolution(p);

  BSLogical containsSolution(BSSet s) =>
      left.containsSolution(s) | right.containsSolution(s);

  BSLogical everyElementIsSolution(BSSet s) =>
      left.everyElementIsSolution(s) | right.everyElementIsSolution(s);

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
