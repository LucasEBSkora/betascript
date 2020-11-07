import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../βs_calculus.dart';
import '../number.dart';
import '../variable.dart';
import '../βs_function.dart';

import '../hyperbolic/ctgh.dart';
import '../single_operand_function.dart';

BSFunction arctgh(BSFunction operand) {
  if (operand is CtgH)
    return operand.operand;
  else
    return ArCtgH._(operand);
}

class ArCtgH extends singleOperandFunction {
  ArCtgH._(BSFunction operand, [Set<Variable> params = null])
      : super(operand,  params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arctgh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_arctgh(op.value) );
    else
      return arctgh(op);
  }
  @override
  BSFunction derivativeInternal(Variable v) =>
      (operand.derivativeInternal(v) / (n(1) - operand ^ n(2)));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArCtgH._(operand, params);
}

double _arctgh(double v) => 0.5 * math.log((v + 1) / (v - 1));
