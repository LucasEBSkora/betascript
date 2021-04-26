import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../inverse_hyperbolic/artanh.dart';

BSFunction tanh(BSFunction operand) {
  return (operand is ArTanH) ? operand.operand : TanH._(operand);
}

class TanH extends SingleOperandFunction {
  const TanH._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return tanh(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_tanh(op.value));
    } else {
      return tanh(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => TanH._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitTanH(this);
}

double _tanh(num v) =>
    (math.exp(v) - math.exp(-v)) / (math.exp(v) + math.exp(-v));
