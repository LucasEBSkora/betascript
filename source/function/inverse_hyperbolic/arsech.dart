import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../hyperbolic/sech.dart';

BSFunction arsech(BSFunction operand) {
  return (operand is SecH) ? operand.operand : ArSecH._(operand);
}

class ArSecH extends SingleOperandFunction {
  const ArSecH._(BSFunction operand, [Set<Variable> params])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arsech(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_arsech(op.value));
    } else {
      return arsech(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params]) => ArSecH._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArSecH(this);
}

double _arsech(double v) => math.log((1 + math.sqrt(1 - math.pow(v, 2))) / v);
