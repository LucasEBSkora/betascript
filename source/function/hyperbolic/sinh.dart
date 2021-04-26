import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../inverse_hyperbolic/arsinh.dart';

BSFunction sinh(BSFunction operand) {
  return (operand is ArSinH) ? operand.operand : SinH._(operand);
}

class SinH extends SingleOperandFunction {
  const SinH._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return sinh(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_sinh(op.value));
    } else {
      return sinh(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => SinH._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitSinH(this);
}

double _sinh(num v) => (math.exp(v) - math.exp(-v)) / 2;
