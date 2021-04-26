import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../trig/sec.dart';

BSFunction arcsec(BSFunction operand) {
  return (operand is Sec) ? operand.operand : ArcSec._(operand);
}

class ArcSec extends SingleOperandFunction {
  const ArcSec._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcsec(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(math.acos(1 / op.value));
    } else {
      return arcsec(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => ArcSec._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArcSec(this);
}
