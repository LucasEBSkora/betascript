import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CosH.dart';
import '../singleOperandFunction.dart';

BSFunction arcosh(BSFunction operand, [bool negative = false]) {
  if (operand is CosH)
    return operand.operand.invertSign(negative);
  else
    return ArCosH._(operand, negative);
}

class ArCosH extends singleOperandFunction {
  ArCosH._(BSFunction operand, [bool negative = false])
      : super(operand, negative);


  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcosh(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_arcosh(op.value) * factor);
    else
      return arcosh(op, negative);
  }

  @override
  BSFunction derivative(Variable v) =>
      (operand.derivative(v) / root((operand ^ n(2)) - n(1)))
          .invertSign(negative);

  @override
  BSFunction withSign(bool negative) => ArCosH._(operand, negative);
}

double _arcosh(double v) => math.log(v + math.sqrt(math.pow(v, 2) - 1));
