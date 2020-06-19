import '../Number.dart';
import '../Variable.dart';
import '../BSFunction.dart';
import '../inverseTrig/ArcCos.dart';
import '../singleOperandFunction.dart';
import 'Sin.dart';
import 'dart:math' as math;

BSFunction cos(BSFunction operand, [bool negative = false]) {
  if (operand is ArcCos)
    return operand.operand.invertSign(negative);
  else
    return Cos._(operand, negative);
}

class Cos extends singleOperandFunction {
  
  Cos._(BSFunction operand, [bool negative = false]) : super(operand, negative);

  @override
  BSFunction derivative(Variable v) =>
      (-sin(operand) * (operand.derivative(v))).invertSign(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) {
      double v = math.cos(op.value) * factor;
      //Doesn't cover nearly enough angles with exact cosines, but will do for now
      if (v == v.toInt()) return n(v);
    }
    return cos(op, negative);
  }

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return n(math.cos(op.value) * factor);
    return cos(op, negative);
  }


  @override
  BSFunction withSign(bool negative) => Cos._(operand, negative);

}
