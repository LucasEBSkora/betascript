import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../function.dart';
import '../visitors/function_visitor.dart';
import '../number.dart';
import '../variable.dart';
import '../hyperbolic/csch.dart';
import '../single_operand_function.dart';

BSFunction arcsch(BSFunction operand) {
  return (operand is CscH) ? operand.operand : ArCscH._(operand);
}

class ArCscH extends SingleOperandFunction {
  const ArCscH._(BSFunction operand, [Set<Variable> params])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) {
    final op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcsch(op);
  }

  @override
  BSFunction get approx {
    final op = operand.approx;
    if (op is Number) {
      return n(_arcsch(op.value));
    } else {
      return arcsch(op);
    }
  }

  @override
  BSFunction copy([Set<Variable> params]) => ArCscH._(operand, params);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitArCscH(this);
}

double _arcsch(double v) => math.log(math.sqrt(1 + math.pow(v, 2)) / v);
