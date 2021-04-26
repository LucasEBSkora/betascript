import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../trig/sin.dart';

BSFunction arcsin(BSFunction operand) {
  return (operand is Sin) ? operand.operand : ArcSin._(operand);
}

class ArcSin extends SingleOperandFunction {
  const ArcSin._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcsin(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(math.asin(op.value));
    } else {
      return arcsin(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => ArcSin._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArcSin(this);
}
