import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../number.dart';
import '../root.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../βs_calculus.dart';
import '../trig/cos.dart';

BSFunction arccos(BSFunction operand) {
  return (operand is Cos) ? operand.operand : ArcCos._(operand);
}

class ArcCos extends singleOperandFunction {
  const ArcCos._(BSFunction operand, [Set<Variable> params])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arccos(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(math.acos(op.value));
    } else {
      return arccos(op);
    }
  }

  @override
  BSFunction derivativeInternal(Variable v) =>
      (-operand.derivativeInternal(v) / root(n(1) - (operand ^ n(2))));

  @override
  BSFunction copy([Set<Variable> params]) => ArcCos._(operand, params);
}
