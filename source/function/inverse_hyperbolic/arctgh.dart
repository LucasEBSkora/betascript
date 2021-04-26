import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../hyperbolic/ctgh.dart';

BSFunction arctgh(BSFunction operand) {
  return (operand is CtgH) ? operand.operand : ArCtgH._(operand);
}

class ArCtgH extends SingleOperandFunction {
  const ArCtgH._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arctgh(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_arctgh(op.value));
    } else {
      return arctgh(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => ArCtgH._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArCtgH(this);
}

double _arctgh(num v) => 0.5 * math.log((v + 1) / (v - 1));
