import 'Exponentiation.dart';
import 'Number.dart';
import 'Variable.dart';
import 'BSFunction.dart';
import 'dart:math' as math;
import 'dart:collection' show SplayTreeSet;
//TODO: Implement roots that aren't square roots

BSFunction root(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is Exponentiation)
    return (operand.base ^ (operand.exponent / n(2))).invertSign(negative);
  else
    return Root._(operand, negative, params);
}

class Root extends BSFunction {
  final BSFunction operand;

  Root._(this.operand, bool negative, Set<Variable> params) : super(negative, params);

  @override
  BSFunction derivative(Variable v) =>
      (n(1 / 2) * (operand ^ n(-1 / 2)) * operand.derivative(v))
          .invertSign(negative);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction opvalue = operand.evaluate(p);
    if (opvalue is Number) {
      double v = math.sqrt(opvalue.value);
      if (v == v.toInt()) {
        //The value has an exact root, and can be returned as a number
        return n(v);
      }
    }
    return root(opvalue, negative); //in any other case, returns a root
  }

  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}sqrt($operand)";

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => Root._(operand, negative, params);

  @override
  SplayTreeSet<Variable> get minParameters => operand.parameters;

  @override
  // TODO: implement approx
  BSFunction get approx {
    BSFunction opvalue = operand.approx;
    if (opvalue
        is Number) //if the operand already evaluates to a number, returns its root
      return n(math.sqrt(opvalue.value));
    else
      return root(opvalue, negative); //in any other case, returns a root
  }
}
