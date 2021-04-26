import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../hyperbolic/sinh.dart';

BSFunction arsinh(BSFunction operand) {
  return (operand is SinH) ? operand.operand : ArSinH._(operand);
}

class ArSinH extends SingleOperandFunction {
  const ArSinH._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arsinh(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_arsinh(op.value));
    } else {
      return arsinh(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => ArSinH._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArSinH(this);
}

double _arsinh(num v) => math.log(v + math.sqrt(1 + math.pow(v, 2)));
