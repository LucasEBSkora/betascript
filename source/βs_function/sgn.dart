import 'abs.dart';
import 'variable.dart';
import 'βs_function.dart';
import 'number.dart';
import 'dart:collection' show HashMap, SplayTreeSet;
import '../utils/tuples.dart';

BSFunction sgn(BSFunction operand) {
      Trio<Number, bool, bool> _f1 = BSFunction.extractFromNegative<Number>(operand);
    if (_f1.second) {
      if (_f1.first.value == 0)
        return n(0);
      else
        return n(_f1.third ? -1 : 1);
    }

    Trio<AbsoluteValue, bool, bool> _f2 =
        BSFunction.extractFromNegative<AbsoluteValue>(operand);
    if (_f2.second) return n(_f2.third ? -1 : 1);

  return Signum._(operand, null);
}

class Signum extends BSFunction {
  final BSFunction operand;

  const Signum._(BSFunction this.operand, [Set<Variable> params = null])
      : super(params);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) => sgn(operand.evaluate(p));

  //The derivative of the sign function is either 0 or undefined.
  @override
  BSFunction derivativeInternal(Variable v) => n(0);

  @override
  String toString([bool handleMinus = true]) => "sign($operand)";

  @override
  BSFunction copy([Set<Variable> params = null]) => Signum._(operand, params);

  SplayTreeSet<Variable> get defaultParameters => operand.parameters;

  @override
  BSFunction get approx => sgn(operand.approx);

}

double sign(double v) {
  if (v == 0)
    return 0;
  else
    return ((v > 0) ? 1 : -1);
}
