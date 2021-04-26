import 'dart:collection' show HashMap;

import 'function.dart';
import 'single_operand_function.dart';
import 'visitors/function_visitor.dart';
import 'number.dart';
import 'variable.dart';

BSFunction negative(BSFunction op) {
  if (op is Negative) return op.operand;
  if (op == n(0))
    return op;
  else
    return Negative._(op);
}

class Negative extends SingleOperandFunction {
  const Negative._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  const Negative(BSFunction operand) : super(operand, const <Variable>{});

  @override
  BSFunction get approx => negative(operand.approx);

  @override
  BSFunction copy([Set<Variable> parameters = const <Variable>{}]) =>
      Negative._(operand, parameters);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) =>
      negative(operand.evaluate(p));

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitNegative(this);
}
