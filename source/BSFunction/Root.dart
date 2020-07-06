import 'Exponentiation.dart';
import 'Number.dart';
import 'Variable.dart';
import 'BSFunction.dart';
import 'dart:math' as math;
import 'dart:collection' show HashMap, SplayTreeSet;
//TODO: Implement roots that aren't square roots

BSFunction root(BSFunction operand) {
  if (operand is Exponentiation)
    return (operand.base ^ (operand.exponent / n(2)));
  else
    return Root._(operand);
}

class Root extends BSFunction {
  final BSFunction operand;

  Root._(this.operand, [Set<Variable> params]) : super(params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (n(1 / 2) * (operand ^ n(-1 / 2)) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction opvalue = operand.evaluate(p);
    if (opvalue is Number) {
      double v = math.sqrt(opvalue.value);
      if (v == v.toInt()) {
        //The value has an exact root, and can be returned as a number
        return n(v);
      }
    }
    return root(opvalue); //in any other case, returns a root
  }

  @override
  String toString([bool handleMinus = true]) =>
      "sqrt($operand)";

  @override
  BSFunction copy([Set<Variable> params = null]) => Root._(operand, params);

  @override
  SplayTreeSet<Variable> get defaultParameters => operand.parameters;

  @override
  BSFunction get approx {
    BSFunction opvalue = operand.approx;
    if (opvalue
        is Number) //if the operand already evaluates to a number, returns its root
      return n(math.sqrt(opvalue.value));
    else
      return root(opvalue); //in any other case, returns a root
  }
}
