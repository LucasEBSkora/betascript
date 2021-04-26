import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../inverse_trig/arctan.dart';

BSFunction tan(BSFunction operand) {
  return (operand is ArcTan) ? operand.operand : Tan._(operand);
}

class Tan extends SingleOperandFunction {
  const Tan._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      double v = math.tan(op.value);
      //Doesn't cover nearly enough angles with exact tangents, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return tan(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) return n(math.tan(op.value));
    return tan(op);
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => Tan._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitTan(this);
}
