import 'bscFunction.dart';
import 'Variable.dart';
import 'dart:math' as math;

bscFunction n(num value) => Number._(value);
bscFunction namedNumber(num absValue, String name, [bool negative = false]) =>
    Number._named(absValue, name, negative);

class constants {
  static const Number e = Number._named(math.e, 'e');
  static const Number pi = Number._named(math.pi, 'π');
}

class Number extends bscFunction {
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
  String toString([bool handleMinus = true]) =>
      ((handleMinus && negative) ? '-' : '') + name;

  @override
  bscFunction derivative(Variable v) => n(0);

  @override
  num call(Map<String, double> p) => value;

  num get value => absvalue * (negative ? -1 : 1);

  @override
  bscFunction withSign(bool negative) {
    if (isNamed)
      return Number._named(absvalue, name, negative);
    else
      return n(absvalue * (negative ? -1 : 1));
  }

  bool operator ==(dynamic other) =>
      (other is Number) && this.value == other.value;

  bool operator <=(dynamic other) => this.value <= other.value;
  bool operator <(dynamic other) => this.value < other.value;
  bool operator >=(dynamic other) => this.value >= other.value;
  bool operator >(dynamic other) => this.value > other.value;
}
