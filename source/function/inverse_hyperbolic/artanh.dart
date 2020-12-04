import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../hyperbolic/tanh.dart';

BSFunction artanh(BSFunction operand) {
  return (operand is TanH) ? operand.operand : ArTanH._(operand);
}

class ArTanH extends SingleOperandFunction {
  const ArTanH._(BSFunction operand, [Set<Variable> params])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return artanh(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_artanh(op.value));
    } else {
      return artanh(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params]) => ArTanH._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArTanH(this);
}

double _artanh(double v) => (1 / 2) * math.log((1 + v) / (1 - v));
