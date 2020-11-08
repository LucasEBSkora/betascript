import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../number.dart';
import '../root.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_calculus.dart';
import '../βs_function.dart';
import '../hyperbolic/sech.dart';

BSFunction arsech(BSFunction operand) {
  return (operand is SecH) ? operand.operand : ArSecH._(operand);
}

class ArSecH extends singleOperandFunction {
  ArSecH._(BSFunction operand, [Set<Variable> params]) : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arsech(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_arsech(op.value));
    } else {
      return arsech(op);
    }
  }

  @override
  BSFunction derivativeInternal(Variable v) => (-operand.derivativeInternal(v) /
      (operand * root(n(1) - (operand ^ n(2)))));

  @override
  BSFunction copy([Set<Variable> params]) => ArSecH._(operand, params);
}

double _arsech(double v) => math.log((1 + math.sqrt(1 - math.pow(v, 2))) / v);
