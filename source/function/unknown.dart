import 'dart:collection';

import 'function.dart';
import 'visitors/function_visitor.dart';
import 'variable.dart';

//Represents a generic, unknown function
class Unknown extends BSFunction {
  final String name;

  final SplayTreeSet<Variable> variables;

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitUnknown(this);

  const Unknown(this.name, this.variables,
      [Set<Variable> params = const <Variable>{}])
      : super(params);

  @override
  BSFunction get approx => this;

  @override
  BSFunction copy(Set<Variable> parameters) =>
      Unknown(name, variables, parameters);

  @override
  SplayTreeSet<Variable> get defaultParameters => variables;

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    for (var variable in variables)
      if (!p.containsKey(variable.name))
        throw BetascriptFunctionError(
            "Error! Missing arguments in call: " + name + " not defined");

    return this;
  }
}

class DerivativeOfUnknown extends Unknown {
  final int order;
  final List<Variable> derivationVariables;

  DerivativeOfUnknown(
      String name, SplayTreeSet<Variable> variables, this.derivationVariables,
      [Set<Variable> params = const <Variable>{}])
      : order = derivationVariables.length,
        super(name, variables, params);

  @override
  T accept<T>(FunctionVisitor visitor) =>
      visitor.visitDerivativeOfUnknown(this);

  @override
  BSFunction copy(Set<Variable> parameters) =>
      DerivativeOfUnknown(name, variables, derivationVariables, parameters);
}
