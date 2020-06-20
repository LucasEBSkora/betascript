import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/SinH.dart';
import '../singleOperandFunction.dart';

BSFunction arsinh(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is SinH)
    return operand.operand.invertSign(negative);
  else
    return ArSinH._(operand, negative, params);
}

class ArSinH extends singleOperandFunction {
  ArSinH._(BSFunction operand, bool negative, Set<Variable> params)
      : super(operand, negative, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arsinh(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_arsinh(op.value) * factor);
    else
      return arsinh(op, negative);
  }
  @override
  BSFunction derivative(Variable v) =>
      (operand.derivative(v) / root(n(1) + (operand ^ n(2))))
          .invertSign(negative);

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => ArSinH._(operand, negative, params);
}

double _arsinh(double v) => math.log(v + math.sqrt(1 + math.pow(v, 2)));
