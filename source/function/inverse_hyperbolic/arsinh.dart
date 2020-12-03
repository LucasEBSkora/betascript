import 'dart:collection' show HashMap;
import 'dart:math' as math;

import '../number.dart';
import '../root.dart';
import '../single_operand_function.dart';
import '../variable.dart';
import '../functions.dart';
import '../function.dart';
import '../hyperbolic/sinh.dart';

BSFunction arsinh(BSFunction operand) {
  return (operand is SinH) ? operand.operand : ArSinH._(operand);
}

class ArSinH extends singleOperandFunction {
  const ArSinH._(BSFunction operand, [Set<Variable> params])
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
  BSFunction derivativeInternal(Variable v) =>
      (operand.derivativeInternal(v) / root(n(1) + (operand ^ n(2))));

  @override
  BSFunction copy([Set<Variable> params]) => ArSinH._(operand, params);
}

double _arsinh(double v) => math.log(v + math.sqrt(1 + math.pow(v, 2)));
