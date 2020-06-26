import '../Abs.dart';
import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../singleOperandFunction.dart';
import '../trig/Csc.dart';

BSFunction arccsc(BSFunction operand) {
  if (operand is Csc)
    return operand.operand;
  else
    return ArcCsc._(operand);
}

class ArcCsc extends singleOperandFunction {
  ArcCsc._(BSFunction operand, [Set<Variable> params = null])
      : super(operand, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arccsc(op);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(math.asin(1 / op.value));
    else
      return arccsc(op);
  }

  @override
  BSFunction derivativeInternal(Variable v) => (operand.derivativeInternal(v) /
      (abs(operand) * root((operand ^ n(2)) - n(1))));

  @override
  BSFunction copy([Set<Variable> params = null]) => ArcCsc._(operand, params);
}
