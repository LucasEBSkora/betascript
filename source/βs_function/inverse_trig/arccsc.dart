import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../abs.dart';
import '../number.dart';
import '../root.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../trig/csc.dart';

BSFunction arccsc(BSFunction operand) {
  return (operand is Csc) ? operand.operand : ArcCsc._(operand);
}

class ArcCsc extends singleOperandFunction {
  ArcCsc._(BSFunction operand, [Set<Variable> params]) : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arccsc(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(math.asin(1 / op.value));
    } else {
      return arccsc(op);
    }
  }

  @override
  BSFunction derivativeInternal(Variable v) => (operand.derivativeInternal(v) /
      (abs(operand) * root((operand ^ n(2)) - n(1))));

  @override
  BSFunction copy([Set<Variable> params]) => ArcCsc._(operand, params);
}
