import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../inverse_hyperbolic/arsech.dart';

BSFunction sech(BSFunction operand) {
  return (operand is ArSecH) ? operand.operand : SecH._(operand);
}

class SecH extends SingleOperandFunction {
  const SecH._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return sech(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_sech(op.value));
    } else {
      return sech(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => SecH._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitSecH(this);
}

double _sech(num v) => 2 / (math.exp(v) + math.exp(-v));
