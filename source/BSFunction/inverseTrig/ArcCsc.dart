import '../Abs.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';
import '../trig/Csc.dart';

BSFunction arccsc(BSFunction operand, [bool negative = false]) {
  if (operand is Csc)
    return operand.operand.invertSign(negative);
  else
    return ArcCsc._(operand, negative);
}

class ArcCsc extends singleOperandFunction {
  ArcCsc._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return arccsc(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.asin(1 / op.value) * factor);
    else
      return arccsc(op, negative);
  }

  @override
  BSFunction derivative(Variable v) =>
      (operand.derivative(v) / (abs(operand) * root((operand ^ n(2)) - n(1))))
          .invertSign(negative);

  @override
  BSFunction withSign(bool negative) => ArcCsc._(operand, negative);
}
