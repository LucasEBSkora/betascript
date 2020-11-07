import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../number.dart';
import '../variable.dart';
import '../βs_function.dart';

import '../inverse_hyperbolic/arctgh.dart';
import '../single_operand_function.dart';
import 'csch.dart';

BSFunction ctgh(BSFunction operand) {
  if (operand is ArCtgH)
    return operand.operand;
  else
    return CtgH._(operand);
}

class CtgH extends singleOperandFunction {
  CtgH._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      ((-csch(operand) ^ n(2)) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return ctgh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_ctgh(op.value) );
    else
      return ctgh(op);
  }

  @override
  BSFunction copy([ Set<Variable> params = null]) => CtgH._(operand, params);
}

double _ctgh(double v) =>
    (math.exp(v) + math.exp(-v)) / (math.exp(v) - math.exp(-v));
