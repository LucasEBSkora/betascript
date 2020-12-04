import 'dart:collection' show HashMap, SplayTreeSet;
import 'dart:math' as math;

import 'function.dart';
import 'visitors/function_visitor.dart';
import 'exponentiation.dart';
import 'number.dart';
import 'variable.dart';
//TODO: Implement roots that aren't square roots

BSFunction root(BSFunction operand) {
  if (operand is Exponentiation)
    return (operand.base ^ (operand.exponent / n(2)));
  else
    return Root._(operand);
}

class Root extends BSFunction {
  final BSFunction operand;

  const Root._(this.operand, [Set<Variable> params]) : super(params);

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
  BSFunction copy([Set<Variable> params]) => Root._(operand, params);

  @override
  SplayTreeSet<Variable> get defaultParameters =>
      SplayTreeSet<Variable>.from(operand.parameters);

  @override
  BSFunction get approx {
    BSFunction opvalue = operand.approx;
    //if the operand already evaluates to a number, returns its root
    if (opvalue is Number) {
      return n(math.sqrt(opvalue.value));
    } else {
      return root(opvalue); //in any other case, returns a root
    }
  }

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitRoot(this);
}
