import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';
import '../trig/Ctg.dart';

BSFunction arcctg(BSFunction operand) {
  if (operand is Ctg)
    return operand.operand;
  else
    return ArcCtg._(operand);
}

class ArcCtg extends singleOperandFunction {
  ArcCtg._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcctg(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.atan(1 / op.value));
    else
      return arcctg(op);
  }

  @override
  BSFunction derivativeInternal(Variable v) =>
      (-operand.derivativeInternal(v) / (n(1) + (operand ^ n(2))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArcCtg._(operand, params);
}
