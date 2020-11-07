import 'dart:collection' show HashMap;
import '../number.dart';
import '../variable.dart';
import '../βs_function.dart';
import 'dart:math' as math;

import '../inverse_hyperbolic/arcosh.dart';
import '../single_operand_function.dart';
import 'sinh.dart';

BSFunction cosh(BSFunction operand) {
  if (operand is ArCosH)
    return operand.operand;
  else
    return CosH._(operand);
}

class CosH extends singleOperandFunction {
  CosH._(BSFunction operand, [Set<Variable> params = null]) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      sinh(operand) * (operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return cosh(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_cosh(op.value));
    else
      return cosh(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => CosH._(operand, params);
}

double _cosh(double v) => (math.exp(v) + math.exp(-v)) / 2;
