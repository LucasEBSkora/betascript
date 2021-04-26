import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../hyperbolic/cosh.dart';

BSFunction arcosh(BSFunction operand) {
  return (operand is CosH) ? operand.operand : ArCosH._(operand);
}

class ArCosH extends SingleOperandFunction {
  const ArCosH._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcosh(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_arcosh(op.value));
    } else {
      return arcosh(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => ArCosH._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArCosH(this);
}

double _arcosh(num v) => math.log(v + math.sqrt(math.pow(v, 2) - 1));
