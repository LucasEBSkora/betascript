import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/SinH.dart';
import '../singleOperandFunction.dart';

BSFunction arsinh(BSFunction operand, [Set<Variable> params = null]) {
  if (operand is SinH)
    return operand.operand;
  else
    return ArSinH._(operand, params);
}

class ArSinH extends singleOperandFunction {
  ArSinH._(BSFunction operand, Set<Variable> params) : super(operand, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arsinh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_arsinh(op.value));
    else
      return arsinh(op);
  }

  @override
  BSFunction derivativeInternal(Variable v) =>
      (operand.derivativeInternal(v) / root(n(1) + (operand ^ n(2))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArSinH._(operand, params);
}

double _arsinh(double v) => math.log(v + math.sqrt(1 + math.pow(v, 2)));
