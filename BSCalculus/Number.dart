import 'bscFunction.dart';
import 'Variable.dart';
import 'dart:math' as math;

class Number extends bscFunction {

  final bool isNamed;

  static const Number e = Number.named(math.e, 'e');

  static Number pi = Number.named(math.pi, 'π');

  final num absvalue;
  final String name;

  Number(num value) : absvalue = value.abs(), name = _makeName(value), isNamed = false, super(value < 0); 

  const Number.named(num this.absvalue, this.name, [bool negative = false]) : isNamed = true,  super(negative);

  static String _makeName(num value) {
    if (value == value.toInt()) return value.toInt().abs().toString();
    else return value.abs().toString();
  }
  @override
  String toString([bool handleMinus = true]) { 
    return 
      ((handleMinus && negative) ? '-' : '') +
      name;
  }

  @override
  bscFunction derivative(Variable v) => Number(0);

  @override
  num evaluate(Map<String, double> p) => value;

  num get value => absvalue * (negative ? -1 : 1);

  @override
  bscFunction withSign(bool negative) {
    if (isNamed) return Number.named(absvalue, name, negative);
    else return Number(value*(negative ? -1 : 1));
  }
}
