import 'dart:collection';

import 'logic_expression.dart';
import '../sets/sets.dart';
import '../βs_function/βs_calculus.dart';

class Constant extends LogicExpression {
  final bool value;

  const Constant(this.value);

  bool get alwaysTrue => value;
  bool get alwaysFalse => !value;

  bool isSolution(HashMap<String, BSFunction> p) => value;

  bool containsSolution(BSSet s) => value;

  bool everyElementIsSolution(BSSet s) => value;

  ///a set with every solution ΒScript can find
  BSSet get solution => (value) ? BSSet.R : emptySet;

  @override
  bool get foundEverySolution => true;

  @override
  SplayTreeSet<String> get parameters => SplayTreeSet();

  @override
  String toString() => "$value";
}
