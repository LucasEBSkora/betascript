import 'dart:collection' show HashMap;
import 'dart:math' as math;

import 'sinh.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../function.dart';
import '../inverse_hyperbolic/arcosh.dart';

BSFunction cosh(BSFunction operand) {
  return (operand is ArCosH) ? operand.operand : CosH._(operand);
}

class CosH extends singleOperandFunction {
  const CosH._(BSFunction operand, [Set<Variable> params])
      : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      sinh(operand) * (operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return cosh(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_cosh(op.value));
    } else {
      return cosh(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params]) => CosH._(operand, params);
}

double _cosh(double v) => (math.exp(v) + math.exp(-v)) / 2;
