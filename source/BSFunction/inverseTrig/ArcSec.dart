import '../Abs.dart';
import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';

BSFunction arcsec(BSFunction operand, [bool negative = false]) {
  if (operand is Sec)
    return operand.operand.invertSign(negative);
  else
    return ArcSec._(operand, negative);
}

class ArcSec extends singleOperandFunction {
  ArcSec._(BSFunction operand, [bool negative = false])
      : super(operand, negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcsec(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.acos(1 / op.value) * factor);
    else
      return arcsec(op, negative);
  }
  @override
  BSFunction derivative(Variable v) =>
      (operand.derivative(v) / (abs(operand) * root((operand ^ n(2)) - n(1))))
          .invertSign(negative);

  @override
  BSFunction withSign(bool negative) => ArcSec._(operand, negative);
}
