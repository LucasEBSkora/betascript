import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../trig/ctg.dart';

BSFunction arcctg(BSFunction operand) {
  return (operand is Ctg) ? operand.operand : ArcCtg._(operand);
}

class ArcCtg extends SingleOperandFunction {
  const ArcCtg._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcctg(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(math.atan(1 / op.value));
    } else {
      return arcctg(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => ArcCtg._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArcCtg(this);
}
