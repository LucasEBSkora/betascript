import 'Exponentiation.dart';
import 'Number.dart';
import 'Variable.dart';
import 'BSFunction.dart';
import 'dart:math' as math;

//TODO: Implement roots that aren't square roots

BSFunction root(BSFunction operand, [bool negative = false]) {
  if (operand is Exponentiation)
    return (operand.base ^ (operand.exponent / n(2))).invertSign(negative);
  else
    return Root._(operand, negative);
}

class Root extends BSFunction {
  final BSFunction operand;

  Root._(this.operand, [bool negative = false]) : super(negative);

  @override
  BSFunction derivative(Variable v) =>
      (n(1 / 2) * (operand ^ n(-1 / 2)) * operand.derivative(v))
          .invertSign(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction opvalue = operand(p);
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
  BSFunction withSign(bool negative) => Root._(operand, negative);

  @override
  Set<Variable> get parameters => operand.parameters;

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
