import 'dart:collection' show HashMap;
import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../inverseHyperbolic/ArCscH.dart';
import '../singleOperandFunction.dart';
import 'CtgH.dart';

BSFunction csch(BSFunction operand) {
  if (operand is ArCscH)
    return operand.operand;
  else
    return CscH._(operand);
}

class CscH extends singleOperandFunction {
  CscH._(BSFunction operand, [Set<Variable> params = null]) : super(operand, params);

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
    if (op is Number)
      return n(_csch(op.value));
    else
      return csch(op);
  }

  @override
  BSFunction copy([Set<Variable> params = null]) => CscH._(operand, params);
}

double _csch(double v) => 2 / (math.exp(v) - math.exp(-v));
