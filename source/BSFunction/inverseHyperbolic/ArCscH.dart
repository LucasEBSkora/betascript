import '../Abs.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CscH.dart';
import '../singleOperandFunction.dart';

BSFunction arcsch(BSFunction operand, [Set<Variable> params = null]) {
  if (operand is CscH)
    return operand.operand;
  else
    return ArCscH._(operand, params);
}

class ArCscH extends singleOperandFunction {
  ArCscH._(BSFunction operand, Set<Variable> params) : super(operand, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcsch(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_arcsch(op.value));
    else
      return arcsch(op);
  }

  @override
  BSFunction derivativeInternal(Variable v) => (-operand.derivativeInternal(v) /
      (abs(operand) * root((operand ^ n(2)) + n(1))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArCscH._(operand, params);
}

double _arcsch(double v) => math.log(math.sqrt(1 + math.pow(v, 2)) / v);
