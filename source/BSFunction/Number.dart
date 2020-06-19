import 'BSFunction.dart';
import 'Variable.dart';
import 'dart:math' as math;

BSFunction n(num value) => Number._(value);
BSFunction namedNumber(num absValue, String name, [bool negative = false]) =>
    Number._named(absValue, name, negative);

class constants {
  static const Number e = Number._named(math.e, 'e');
  static const Number pi = Number._named(math.pi, 'π');
}

class Number extends BSFunction {
  final bool isNamed;
  final num absvalue;
  final String name;
  final bool isInt;

  Number._(num value)
      : absvalue = value.abs(),
        name = _makeName(value),
        isInt = (value == value.toInt()),
        isNamed = false,
        super(value < 0);

  const Number._named(num this.absvalue, this.name, [bool negative = false])
      : isNamed = true,
        isInt = (absvalue is int),
        super(negative);

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
  BSFunction call(Map<String, BSFunction> p) => this;

  num get value => absvalue * factor;

  @override
  BSFunction withSign(bool negative) {
    if (isNamed)
      return Number._named(absvalue, name, negative);
    else
      return n(absvalue * factor);
  }

  @override
  Set<Variable> get parameters => Set();
  

  bool operator ==(dynamic other) =>
      (other is Number) && this.value == other.value;

  bool operator <=(dynamic other) => this.value <= other.value;
  bool operator <(dynamic other) => this.value < other.value;
  bool operator >=(dynamic other) => this.value >= other.value;
  bool operator >(dynamic other) => this.value > other.value;

  @override
  BSFunction get approx => n(value); //only difference is that it ignores named numbers

}
