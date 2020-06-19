import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';

BSFunction arccos(BSFunction operand, [bool negative = false]) {
  if (operand is Cos)
    return operand.operand.invertSign(negative);
  else
    return ArcCos._(operand, negative);
}

class ArcCos extends singleOperandFunction {
  ArcCos._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return arccos(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.acos(op.value) * factor);
    else
      return arccos(op, negative);
  }

  @override
  BSFunction derivative(Variable v) =>
      (-operand.derivative(v) / root(n(1) - (operand ^ n(2))))
          .invertSign(negative);

  @override
  BSFunction withSign(bool negative) => ArcCos._(operand, negative);
}
