import 'dart:collection' show HashMap;
import 'dart:math' as math;

import 'csch.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../inverse_hyperbolic/arctgh.dart';

BSFunction ctgh(BSFunction operand) {
  return (operand is ArCtgH) ? operand.operand : CtgH._(operand);
}

class CtgH extends singleOperandFunction {
  const CtgH._(BSFunction operand, [Set<Variable> params])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      ((-csch(operand) ^ n(2)) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return ctgh(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_ctgh(op.value));
    } else {
      return ctgh(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params]) => CtgH._(operand, params);
}

double _ctgh(double v) =>
    (math.exp(v) + math.exp(-v)) / (math.exp(v) - math.exp(-v));
