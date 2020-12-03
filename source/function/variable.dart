import 'dart:collection' show HashMap, SplayTreeSet;

import 'number.dart';
import 'functions.dart';
import 'function.dart';

Variable variable(String name, [Set<Variable> params]) =>
    Variable._(name, params);

class Variable extends BSFunction implements Comparable {
  final String name;

  const Variable._(this.name, Set<Variable> params) : super(params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    if (!p.containsKey(name)) {
      throw BetascriptFunctionError(
          "Error! Missing arguments in call call: " + name + " not defined");
    }
    return p[name];
  }

  @override
  BSFunction derivativeInternal(Variable v) => n((v.name == name) ? 1 : 0);

  @override
  String toString() => name;

  @override
  BSFunction copy([Set<Variable> params]) => Variable._(name, parameters);

  @override
  SplayTreeSet<Variable> get defaultParameters => SplayTreeSet.from([this]);

  @override
  BSFunction get approx => this;

  @override
  int compareTo(Object other) {
    if (other is Variable) {
      return name.compareTo(other.name);
    } else
      throw Exception("Can't compare Variable with ${other.runtimeType}!");
  }
}
