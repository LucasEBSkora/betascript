import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../βs_calculus.dart';
import '../number.dart';
import '../variable.dart';
import '../βs_function.dart';

import '../single_operand_function.dart';
import '../trig/tan.dart';

BSFunction arctan(BSFunction operand) {
  if (operand is Tan)
    return operand.operand;
  else
    return ArcTan._(operand);
}

class ArcTan extends singleOperandFunction {
  ArcTan._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arctan(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.atan(op.value));
    else
      return arctan(op);
  }

  @override
  BSFunction derivativeInternal(Variable v) =>
      (operand.derivativeInternal(v) / (n(1) + (operand ^ n(2))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArcTan._(operand, params);
}
