import 'bscFunction.dart';
import 'Variable.dart';
import 'dart:math' as math;

class Number extends bscFunction {
  static const Number e = Number.named(math.e, 'e');
  static Number pi = Number.named(math.pi, 'π');

  final bool isNamed;
  final num absvalue;
  final String name;
  final bool isInt;

  Number(num value)
      : absvalue = value.abs(),
        name = _makeName(value),
        isInt = (value == value.toInt()),
        isNamed = false,
        super(value < 0);

  const Number.named(num this.absvalue, this.name, [bool negative = false])
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
  bscFunction derivative(Variable v) => Number(0);

  @override
  num call(Map<String, double> p) => value;

  num get value => absvalue * (negative ? -1 : 1);

  @override
  bscFunction withSign(bool negative) {
    if (isNamed)
      return Number.named(absvalue, name, negative);
    else
      return Number(absvalue * (negative ? -1 : 1));
  }
}
