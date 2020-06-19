import 'Sgn.dart';
import 'Variable.dart';
import 'BSFunction.dart';
import 'Number.dart';

BSFunction abs(BSFunction operand, [bool negative = false]) {
  if (operand is Number) return operand.withSign(negative);
  else return AbsoluteValue._(operand, negative);
}

class AbsoluteValue extends BSFunction {
  
  final BSFunction operand;

  AbsoluteValue._(BSFunction this.operand, [bool negative = false]) : super(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    BSFunction op = operand(p);
    if (op is Number) return op.ignoreNegative;
    else return abs(op, negative);
  }

  @override
  BSFunction derivative(Variable v) => (sgn(operand)*operand.derivative(v)).invertSign(negative);

  @override
  String toString([bool handleMinus = true]) => "${minusSign(handleMinus)}|${operand}|";

  @override
  BSFunction withSign(bool negative) => AbsoluteValue._(operand, negative);

  @override
  Set<Variable> get parameters => operand.parameters;

  @override
  BSFunction get approx {
    BSFunction op = operand.approx;
    if (op is Number) return op.ignoreNegative;
    else return abs(op, negative);
  }

}
