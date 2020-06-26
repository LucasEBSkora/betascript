import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CtgH.dart';
import '../singleOperandFunction.dart';

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
  BSFunction evaluate(Map<String, BSFunction> p) {
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
