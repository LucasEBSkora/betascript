import 'dart:collection' show HashMap;
import 'dart:math' as math;

import 'tanh.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../βs_function.dart';
import '../inverse_hyperbolic/arsech.dart';

BSFunction sech(BSFunction operand) {
  return (operand is ArSecH) ? operand.operand : SecH._(operand);
}

class SecH extends singleOperandFunction {
  SecH._(BSFunction operand, [Set<Variable> params]) : super(operand, params);

  @override
  BSFunction derivativeInternal(Variable v) =>
      (-sech(operand) * tanh(operand) * operand.derivativeInternal(v));

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return sech(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_sech(op.value));
    } else {
      return sech(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params]) => SecH._(operand, params);
}

double _sech(double v) => 2 / (math.exp(v) + math.exp(-v));
