import 'βs_function.dart';
import 'negative.dart';
import 'variable.dart';
import 'dart:math' as math;
import 'dart:collection' show HashMap, SplayTreeSet;

BSFunction n(num value) {
  if (value < 0) return negative(Number._(value.abs(), null));
  return Number._(value);
}

BSFunction namedNumber(num absValue, String name) =>
    Number._named(absValue, name);

class constants {
  static const Number e = Number._named(math.e, 'e', null);
  static const Number pi = Number._named(math.pi, 'π', null);
  static const Number infinity = Number._named(double.infinity, '∞', null);
  static const Negative negativeInfinity = Negative(infinity);
}

class Number extends BSFunction {
  final bool isNamed;
  final num absvalue;
  final String name;
  final bool isInt;

  Number._(num value, [Set<Variable> params = null])
      : absvalue = value.abs(),
        name = _makeName(value),
        isInt = (value == value.toInt()),
        isNamed = false,
        super(params);

  const Number._named(num this.absvalue, this.name,
      [Set<Variable> params = null])
      : isNamed = true,
        isInt = (absvalue is int),
        super(params);

  ///creates a name from the number, but if it can be cast to a int, does it (so 1.0 is displayed as 1)
  static String _makeName(num value) {
    if (value == value.toInt())
      return value.toInt().abs().toString();
    else
      return value.abs().toString();
  }

  @override
  String toString([bool handleMinus = true]) => name;

  @override
  BSFunction derivativeInternal(Variable v) => n(0);

  @override
  BSFunction evaluate(HashMap<String, BSFunction> p) => this;

  num get value => absvalue;

  @override
  BSFunction copy([Set<Variable> params = null]) {
    if (isNamed)
      return Number._named(absvalue, name, params);
    else
      return Number._(absvalue, params);
  }

  @override
  SplayTreeSet<Variable> get defaultParameters => SplayTreeSet();

  bool operator ==(dynamic other) =>
      (other is Number) && this.value == other.value;

  @override
  BSFunction get approx => n(value);
}
