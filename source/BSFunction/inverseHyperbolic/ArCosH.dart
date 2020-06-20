import '../BSCalculus.dart';
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CosH.dart';
import '../singleOperandFunction.dart';

BSFunction arcosh(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is CosH)
    return operand.operand.invertSign(negative);
  else
    return ArCosH._(operand, negative, params);
}

class ArCosH extends singleOperandFunction {
  ArCosH._(BSFunction operand, bool negative, Set<Variable> params)
      : super(operand, negative, params);


  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
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
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => ArCosH._(operand, negative, params);
}

double _arcosh(double v) => math.log(v + math.sqrt(math.pow(v, 2) - 1));
