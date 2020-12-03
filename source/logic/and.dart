import 'dart:collection' show HashMap, SplayTreeSet;

import 'constant.dart';
import 'logic_expression.dart';
import '../sets/sets.dart';
import '../utils/three_valued_logic.dart';
import '../function/functions.dart';

LogicExpression and(LogicExpression left, LogicExpression right) {
  // (1 && A) == A, (0 && A) == 0
  if (left is Constant) {
    if (left.value == bsUnknown) return left;
    return (left.value.asBool()) ? right : left;
  }
  if (right is Constant) {
    if (right.value == bsUnknown) return right;
    return (right.value.asBool()) ? left : right;
  }

  return And(left, right);
}

class And extends LogicExpression {
  final LogicExpression left;
  final LogicExpression right;

  const And(this.left, this.right);

  BSLogical get alwaysTrue => left.alwaysTrue & right.alwaysTrue;

  BSLogical get alwaysFalse => left.alwaysFalse | right.alwaysFalse;

  BSLogical isSolution(HashMap<String, BSFunction> p) =>
      left.isSolution(p) & right.isSolution(p);

  BSLogical containsSolution(BSSet s) =>
      left.containsSolution(s) & right.containsSolution(s);

  BSLogical everyElementIsSolution(BSSet s) =>
      left.everyElementIsSolution(s) & right.everyElementIsSolution(s);

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
