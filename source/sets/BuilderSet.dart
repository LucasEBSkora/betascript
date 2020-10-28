import 'dart:collection';

import '../BSFunction/BSFunction.dart';
import '../BSFunction/Variable.dart';

import 'BSSet.dart';

import '../Logic/Logic.dart';

BSSet builderSet(LogicExpression rule, List<Variable> parameters) {
  BSSet sol = rule.solution;
  if (rule.foundEverySolution)
    return sol;
  else
    return BuilderSet(rule, parameters);
}

class BuilderSet extends BSSet {
  final List<Variable> parameters;
  final LogicExpression rule;

  BuilderSet(this.rule, List<Variable> this.parameters);

  @override
  bool belongs(BSFunction x) =>
      rule.isSolution(HashMap.from({rule.parameters.last: x}));

  @override
  BSSet complement() {
    return BuilderSet(Not(rule), parameters);
  }

  BSSet get knownElements => rule.solution;

  @override
  String toString() {
    String params = rule.parameters.reduce((previousValue, element) => "$previousValue, $element");
    return "{$params | $rule}";
  }
}
