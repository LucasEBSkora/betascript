import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/SecH.dart';
import '../singleOperandFunction.dart';

BSFunction arsech(BSFunction operand) {
  if (operand is SecH)
    return operand.operand;
  else
    return ArSecH._(operand);
}

class ArSecH extends singleOperandFunction {
  ArSecH._(BSFunction operand, [Set<Variable> params = null]) : super(operand, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arsech(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_arsech(op.value));
    else
      return arsech(op);
  }

  @override
  BSFunction derivativeInternal(Variable v) => (-operand.derivativeInternal(v) /
      (operand * root(n(1) - (operand ^ n(2)))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArSecH._(operand, params);
}

double _arsech(double v) => math.log((1 + math.sqrt(1 - math.pow(v, 2))) / v);
