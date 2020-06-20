import '../Number.dart';
import '../Root.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import 'dart:math' as math;

import '../hyperbolic/CscH.dart';
import '../singleOperandFunction.dart';

BSFunction arcsch(BSFunction operand, [bool negative = false, Set<Variable> params = null]) {
  if (operand is CscH)
    return operand.operand.invertSign(negative);
  else
    return ArCscH._(operand, negative, params);
}

class ArCscH extends singleOperandFunction {

  ArCscH._(BSFunction operand, bool negative, Set<Variable> params) : super(operand, negative, params);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) {
    BSFunction op = operand.evaluate(p);
    if (op is Number) {
      //put simplifications here
    }
    return arcsch(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number)
      return n(_arcsch(op.value) * factor);
    else
      return arcsch(op, negative);
  }
  @override
  BSFunction derivative(Variable v) =>
      (-operand.derivative(v) / (operand * root((operand ^ n(2)) + n(1))))
          .invertSign(negative);

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) => ArCscH._(operand, negative, params);

}

double _arcsch(double v) => math.log(math.sqrt(1 + math.pow(v, 2)) / v);
