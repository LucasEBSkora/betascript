import 'dart:collection' show HashMap, SplayTreeSet;

import 'function.dart';
import 'visitors/function_visitor.dart';

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

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitVariable(this);
}
