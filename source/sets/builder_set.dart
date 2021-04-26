import 'dart:collection';

import 'set.dart';
import '../logic/logic.dart';
import '../function/variable.dart';
import '../function/function.dart';
import 'visitor/set_visitor.dart';

BSSet builderSet(LogicExpression rule, [List<Variable> parameters = const <Variable>[]]) {
  final sol = rule.solution;
  if (rule.foundEverySolution) {
    return sol;
  } else {
    return BuilderSet(rule,
        rule.parameters.map<Variable>((element) => variable(element)).toList());
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

  @override
  BSSet get knownElements => rule.solution;

  @override
  ReturnType accept<ReturnType>(SetVisitor visitor) =>
      visitor.visitBuilderSet(this);

  @override
  bool get isIntensional => true;
}
