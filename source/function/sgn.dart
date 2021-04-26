import 'dart:collection' show HashMap;

import 'abs.dart';
import 'function.dart';
import 'single_operand_function.dart';
import 'number.dart';
import 'utils.dart' show extractFromNegative;
import 'variable.dart';
import 'visitors/function_visitor.dart';

BSFunction sgn(BSFunction operand) {
  final _f1 = extractFromNegative(operand);
  if (_f1.first is Number) {
    return ((_f1.first as Number).value == 0) ? n(0) : n(_f1.second ? -1 : 1);
  }

  if (_f1.first is AbsoluteValue) return n(_f1.second ? -1 : 1);

  return Signum._(operand);
}

class Signum extends SingleOperandFunction {
  const Signum._(BSFunction operand, [Set<Variable> params = const <Variable>{}])
      : super(operand, params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) =>
      sgn(operand.evaluate(p));

  @override
  BSFunction copy([Set<Variable> params = const <Variable>{}]) => Signum._(operand, params);

  @override
  BSFunction get approx => sgn(operand.approx);

  @override
  T accept<T>(FunctionVisitor visitor) => visitor.visitSignum(this);
}

double sign(num v) {
  return (v == 0) ? 0 : ((v > 0) ? 1 : -1);
}
