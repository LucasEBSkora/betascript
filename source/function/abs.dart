import 'dart:collection' show HashMap;

import 'function.dart';
import 'single_operand_function.dart';
import 'visitors/function_visitor.dart';
import 'negative.dart';
import 'number.dart';
import 'variable.dart';

BSFunction abs(BSFunction operand) {
  //It makes no sense to keep a negative sign inside a absolute value.
  if (operand is Negative) operand = (operand as Negative).operand;

  //If the operand is a number, it can be returned directly, since it will always have the same absolute value
  if (operand is Number) return operand;

  return AbsoluteValue._(operand);
}

class AbsoluteValue extends SingleOperandFunction {
  const AbsoluteValue._(BSFunction operand, [Set<Variable> params])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) =>
      abs(operand.evaluate(p));

  @override
  BSFunction copy([Set<Variable> params]) => AbsoluteValue._(operand, params);

  @override
  BSFunction get approx => abs(operand.approx);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitAbs(this);
}
