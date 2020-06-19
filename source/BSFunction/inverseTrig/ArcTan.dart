import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';

BSFunction arctan(BSFunction operand, [bool negative = false]) {
  if (operand is Tan)
    return operand.operand.invertSign(negative);
  else
    return ArcTan._(operand, negative);
}

class ArcTan extends singleOperandFunction {
  ArcTan._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return arctan(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.atan(op.value) * factor);
    else
      return arctan(op, negative);
  }
  @override
  BSFunction derivative(Variable v) =>
      (operand.derivative(v) / (n(1) + (operand ^ n(2)))).invertSign(negative);

  @override
  BSFunction withSign(bool negative) => ArcTan._(operand, negative);
}
