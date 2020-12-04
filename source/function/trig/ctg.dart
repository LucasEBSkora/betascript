import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../inverse_trig/arcctg.dart';

BSFunction ctg(BSFunction operand) {
  return (operand is ArcCtg) ? operand.operand : Ctg._(operand);
}

class Ctg extends SingleOperandFunction {
  const Ctg._(BSFunction operand, [Set<Variable> params])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      double v = 1 / math.tan(op.value);
      //Doesn't cover nearly enough angles with exact cotagents, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return ctg(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) return n(1 / math.tan(op.value));
    return ctg(op);
  }

  @override
  BSFunction copy([Set<Variable> params]) => Ctg._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitCtg(this);
}
