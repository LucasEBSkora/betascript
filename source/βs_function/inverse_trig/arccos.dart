import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../βs_calculus.dart';
import '../number.dart';
import '../variable.dart';
import '../βs_function.dart';

import '../single_operand_function.dart';
import '../trig/cos.dart';
import '../root.dart';

BSFunction arccos(BSFunction operand) {
  if (operand is Cos)
    return operand.operand;
  else
    return ArcCos._(operand);
}

class ArcCos extends singleOperandFunction {
  ArcCos._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arccos(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.acos(op.value));
    else
      return arccos(op);
  }

  @override
  BSFunction derivativeInternal(Variable v) =>
      (-operand.derivativeInternal(v) / root(n(1) - (operand ^ n(2))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArcCos._(operand, params);
}
