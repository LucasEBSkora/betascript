import '../Abs.dart';
import '../BSCalculus.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';

BSFunction arcsec(BSFunction operand, [Set<Variable> params = null]) {
  if (operand is Sec)
    return operand.operand;
  else
    return ArcSec._(operand, params);
}

class ArcSec extends singleOperandFunction {
  ArcSec._(BSFunction operand,  Set<Variable> params)
      : super(operand, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcsec(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.acos(1 / op.value));
    else
      return arcsec(op);
  }
  @override
  BSFunction derivativeInternal(Variable v) =>
      (operand.derivativeInternal(v) / (abs(operand) * root((operand ^ n(2)) - n(1))))
          ;

  @override
  BSFunction copy([Set<Variable> params = null]) => ArcSec._(operand, params);
}
