import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../trig/tan.dart';

BSFunction arctan(BSFunction operand) {
  return (operand is Tan) ? operand.operand : ArcTan._(operand);
}

class ArcTan extends SingleOperandFunction {
  const ArcTan._(BSFunction operand, [Set<Variable> params])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arctan(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(math.atan(op.value));
    } else {
      return arctan(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params]) => ArcTan._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArcTan(this);
}
