import 'dart:collection' show HashMap;
import 'dart:math' as math;

import 'cosh.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../inverse_hyperbolic/arsinh.dart';

BSFunction sinh(BSFunction operand) {
  return (operand is ArSinH) ? operand.operand : SinH._(operand);
}

class SinH extends singleOperandFunction {
  SinH._(BSFunction operand, [Set<Variable> params]) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (cosh(operand) * (operand.derivativeInternal(v)));
  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return sinh(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_sinh(op.value));
    } else {
      return sinh(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params]) => SinH._(operand, params);
}

double _sinh(double v) => (math.exp(v) - math.exp(-v)) / 2;
