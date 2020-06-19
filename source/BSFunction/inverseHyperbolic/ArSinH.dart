import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/SinH.dart';
import '../singleOperandFunction.dart';

BSFunction arsinh(BSFunction operand, [bool negative = false]) {
  if (operand is SinH)
    return operand.operand.invertSign(negative);
  else
    return ArSinH._(operand, negative);
}

class ArSinH extends singleOperandFunction {
  ArSinH._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
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
  BSFunction withSign(bool negative) => ArSinH._(operand, negative);
}

double _arsinh(double v) => math.log(v + math.sqrt(1 + math.pow(v, 2)));
