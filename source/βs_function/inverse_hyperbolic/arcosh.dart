import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../number.dart';
import '../root.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../βs_calculus.dart';
import '../hyperbolic/cosh.dart';

BSFunction arcosh(BSFunction operand) {
  return (operand is CosH) ? operand.operand : ArCosH._(operand);
}

class ArCosH extends singleOperandFunction {
  ArCosH._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcosh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) {
      return n(_arcosh(op.value));
    } else {
      return arcosh(op);
    }
  }

  @override
  BSFunction derivativeInternal(Variable v) =>
      (operand.derivativeInternal(v) / root((operand ^ n(2)) - n(1)));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArCosH._(operand, params);
}

double _arcosh(double v) => math.log(v + math.sqrt(math.pow(v, 2) - 1));
