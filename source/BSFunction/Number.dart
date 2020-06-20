import 'BSFunction.dart';
import 'Variable.dart';
import 'dart:math' as math;
import 'dart:collection' show SplayTreeSet;

BSFunction n(num value, [Set<Variable> params = null]) =>
    Number._(value, params);
BSFunction namedNumber(num absValue, String name,
        [bool negative = false, Set<Variable> params = null]) =>
    Number._named(absValue, name, negative, params);

class constants {
  static const Number e = Number._named(math.e, 'e', false, null);
  static const Number pi = Number._named(math.pi, 'π', false, null);
}

class Number extends BSFunction {
  final bool isNamed;
  final num absvalue;
  final String name;
  final bool isInt;

  Number._(num value, Set<Variable> params)
      : absvalue = value.abs(),
        name = _makeName(value),
        isInt = (value == value.toInt()),
        isNamed = false,
        super(value < 0, params);

  const Number._named(
      num this.absvalue, this.name, bool negative, Set<Variable> params)
      : isNamed = true,
        isInt = (absvalue is int),
        super(negative, params);

  ///creates a name from the number, but if it can be cast to a int, does it (so 1.0 is displayed as 1)
  static String _makeName(num value) {
    if (value == value.toInt())
      return value.toInt().abs().toString();
    else
      return value.abs().toString();
  }

  @override
  String toString([bool handleMinus = true]) => minusSign(handleMinus) + name;

  @override
  BSFunction derivative(Variable v) => n(0);

  @override
  BSFunction evaluate(Map<String, BSFunction> p) => this;

  num get value => absvalue * factor;

  @override
  BSFunction copy([bool negative = null, Set<Variable> params = null]) {
    if (isNamed)
      return Number._named(absvalue, name, negative, params);
    else
      return Number._(absvalue * factor, params);
  }

  @override
  SplayTreeSet<Variable> get minParameters => SplayTreeSet();

  bool operator ==(dynamic other) =>
      (other is Number) && this.value == other.value;

  bool operator <=(dynamic other) => this.value <= other.value;
  bool operator <(dynamic other) => this.value < other.value;
  bool operator >=(dynamic other) => this.value >= other.value;
  bool operator >(dynamic other) => this.value > other.value;

  @override
  BSFunction get approx =>
      n(value); //only difference is that it ignores named numbers

}
