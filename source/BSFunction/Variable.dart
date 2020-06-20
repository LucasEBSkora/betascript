import 'dart:io';
import 'BSCalculus.dart';
import 'BSFunction.dart';
import 'Number.dart';
import 'dart:collection' show SplayTreeSet;

BSFunction variable(String name,
        [bool negative = false, Set<Variable> params = null]) =>
    Variable._(name, negative, params);

class Variable extends BSFunction implements Comparable {
  final String name;

  Variable._(String this.name, bool negative, Set<Variable> params)
      : super(negative, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    if (!p.containsKey(name)) {
      print("Error! Missing arguments in call call: " + name + " not defined");
      exit(1);
    }
    return p[name].copy(negative);
  }

  @override
  BSFunction derivative(Variable v) {
    if (v.name == this.name)
      return n(1).copy(negative);
    else
      return n(0);
  }

  @override
  String toString([bool handleMinus = true]) => minusSign(handleMinus) + name;

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) =>
      Variable._(name, negative, params);

  @override
  SplayTreeSet<Variable> get minParameters => SplayTreeSet.from([this]);

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
