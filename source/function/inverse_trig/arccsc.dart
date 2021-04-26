import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../trig/csc.dart';

BSFunction arccsc(BSFunction operand) {
  return (operand is Csc) ? operand.operand : ArcCsc._(operand);
}

class ArcCsc extends SingleOperandFunction {
  const ArcCsc._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arccsc(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(math.asin(1 / op.value));
    } else {
      return arccsc(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => ArcCsc._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArcCsc(this);
}
