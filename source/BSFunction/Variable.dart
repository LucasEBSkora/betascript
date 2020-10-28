import 'BSCalculus.dart';
import 'BSFunction.dart';
import 'Number.dart';
import 'dart:collection' show HashMap, SplayTreeSet;

BSFunction variable(String name, [Set<Variable> params = null]) =>
    Variable._(name, params);

class Variable extends BSFunction implements Comparable {
  final String name;

  Variable._(String this.name, Set<Variable> params) : super(params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    if (!p.containsKey(name)) 
      throw BetascriptFunctionError("Error! Missing arguments in call call: " + name + " not defined");
    return p[name];
  }

  @override
  BSFunction derivativeInternal(Variable v) => n((v.name == this.name) ? 1 : 0);

  @override
  String toString() => name;

  @override
  BSFunction copy([Set<Variable> params = null]) =>
      Variable._(name, this.parameters);

  @override
  SplayTreeSet<Variable> get defaultParameters => SplayTreeSet.from([this]);

  @override
  BSFunction get approx => this;

  @override
  int compareTo(dynamic other) {
    if (other is Variable) {
      return name.compareTo(other.name);
    } else
      throw new Exception("Can't compare Variable with ${other.runtimeType}!");
  }
}
