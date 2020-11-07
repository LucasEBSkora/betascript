import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../abs.dart';
import '../βs_calculus.dart';
import '../number.dart';
import '../root.dart';
import '../variable.dart';
import '../βs_function.dart';

import '../single_operand_function.dart';
import '../trig/sec.dart';

BSFunction arcsec(BSFunction operand) {
  return (operand is Sec) ? operand.operand : ArcSec._(operand);
  if (operand is Sec)
    return operand.operand;
  else
    return ArcSec._(operand);
}

class ArcSec extends singleOperandFunction {
  ArcSec._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcsec(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) {
      return n(math.acos(1 / op.value));
    } else {
      return arcsec(op);
    }
  }

  @override
  BSFunction derivativeInternal(Variable v) => (operand.derivativeInternal(v) /
      (abs(operand) * root((operand ^ n(2)) - n(1))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArcSec._(operand, params);
}
