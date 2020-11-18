import 'dart:collection';

import 'logic_expression.dart';
import '../sets/sets.dart';
import '../utils/three_valued_logic.dart';
import '../βs_function/βs_calculus.dart';

class Constant extends LogicExpression {
  final BSLogical value;

  const Constant(this.value);

  BSLogical get alwaysTrue => value;
  BSLogical get alwaysFalse => -value;

  BSLogical isSolution(HashMap<String, BSFunction> p) => value;

  BSLogical containsSolution(BSSet s) => value;

  BSLogical everyElementIsSolution(BSSet s) => value;

  ///a set with every solution ΒScript can find
  BSSet get solution => (value.asBool()) ? BSSet.R : emptySet;

  @override
  bool get foundEverySolution => true;

  @override
  SplayTreeSet<String> get parameters => SplayTreeSet();

  @override
  String toString() => "$value";
}
