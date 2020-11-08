import 'dart:collection' show HashMap, SplayTreeSet;

import 'constant.dart';
import 'logic_expression.dart';
import '../sets/sets.dart';
import '../βs_function/βs_calculus.dart';

LogicExpression not(LogicExpression operand) {
  return (operand is Constant) ? Constant(!operand.value) : Not(operand);
}

class Not extends LogicExpression {
  final LogicExpression operand;

  const Not(this.operand);

  bool get alwaysTrue => operand.alwaysFalse;

  bool get alwaysFalse => operand.alwaysTrue;

  bool isSolution(HashMap<String, BSFunction> p) => !operand.isSolution(p);

  bool containsSolution(BSSet s) => !operand.everyElementIsSolution(s);

  bool everyElementIsSolution(BSSet s) => !operand.containsSolution(s);

  BSSet get solution => operand.solution.complement();

  @override
  String toString() => "not ($operand)";

  @override
  SplayTreeSet<String> get parameters => operand.parameters;

  @override
  bool get foundEverySolution => operand.foundEverySolution;
}
