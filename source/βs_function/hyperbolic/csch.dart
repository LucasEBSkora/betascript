import 'dart:collection' show HashMap;
import 'dart:math' as math;

import 'ctgh.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../inverse_hyperbolic/arcsch.dart';

BSFunction csch(BSFunction operand) {
  return (operand is ArCscH) ? operand.operand : CscH._(operand);
}

class CscH extends singleOperandFunction {
  CscH._(BSFunction operand, [Set<Variable> params]) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (-csch(operand) * ctgh(operand) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return csch(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) {
      return n(_csch(op.value));
    } else {
      return csch(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params]) => CscH._(operand, params);
}

double _csch(double v) => 2 / (math.exp(v) - math.exp(-v));
