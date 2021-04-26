import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../trig/cos.dart';

BSFunction arccos(BSFunction operand) {
  return (operand is Cos) ? operand.operand : ArcCos._(operand);
}

class ArcCos extends SingleOperandFunction {
  const ArcCos._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
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
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => ArcCos._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArcCos(this);
}
