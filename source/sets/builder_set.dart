import 'dart:collection';

import 'set.dart';
import '../logic/logic.dart';
import '../function/variable.dart';
import '../function/function.dart';

BSSet builderSet(LogicExpression rule, [List<Variable> parameters]) {
  final sol = rule.solution;
  if (rule.foundEverySolution) {
    return sol;
  } else {
    if (parameters == null) {
      parameters = rule.parameters
          .map<Variable>((element) => variable(element))
          .toList();
    }
    return BuilderSet(rule, parameters);
  }
}

class BuilderSet extends BSSet {
  final List<Variable> parameters;
  final LogicExpression rule;

  const BuilderSet(this.rule, this.parameters);

  @override
  bool belongs(BSFunction x) =>
      rule.isSolution(HashMap.from({rule.parameters.last: x})).asBool();

  @override
  BSSet complement() => BuilderSet(Not(rule), parameters);

  BSSet get knownElements => rule.solution;

  @override
  String toString() =>
      "{${rule.parameters.reduce((previousValue, element) => "$previousValue, $element")} | $rule}";
}
