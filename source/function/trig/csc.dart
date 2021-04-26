import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../inverse_trig/arccsc.dart';

BSFunction csc(BSFunction operand) {
  return (operand is ArcCsc) ? operand.operand : Csc._(operand);
}

class Csc extends SingleOperandFunction {
  const Csc._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      double v = 1 / math.sin(op.value);
      //Doesn't cover nearly enough angles with exact cossecants, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return csc(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) return n(1 / math.sin(op.value));
    return csc(op);
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => Csc._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitCsc(this);
}
