import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';

import '../singleOperandFunction.dart';
import '../trig/Sin.dart';

BSFunction arcsin(BSFunction operand) {
  if (operand is Sin)
    return operand.operand;
  else
    return ArcSin._(operand);
}

class ArcSin extends singleOperandFunction {
  ArcSin._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcsin(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.asin(op.value));
    else
      return arcsin(op);
  }

  @override
  BSFunction derivativeInternal(Variable v) =>
      (operand.derivativeInternal(v) / root(n(1) - (operand ^ n(2))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArcSin._(operand, params);
}
