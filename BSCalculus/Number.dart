import 'bscFunction.dart';
import 'Variable.dart';
import 'dart:math' as math;

class Number extends bscFunction {

  static const Number e = Number.named(math.e, 'e');

  //TODO: discover how to print unicode (would it even work on the terminal?)
  static Number pi = Number.named(math.pi, 'pi');

  final num value;
  final String name;

  Number(num value) : value = value.abs(), name = value.abs().toString(), super(value < 0); 

  const Number.named(num this.value, this.name, [bool negative = false]) :  super(negative);

  
  @override
  String toString([bool handleMinus = true]) { 
    print('"' + name + "'");
    return 
      ((handleMinus && negative) ? '-' : '') +
      name;
  }

  @override
  bscFunction derivative(Variable v) {
    
    return Number(0);
  }

  @override
  num evaluate(Map<String, double> p) {
    return value* (negative ? -1 : 1);
  }

  @override
  bscFunction ignoreNegative() { 
    return Number.named(value, name, false);
  }

  @override
  bscFunction opposite() {
    return Number.named(value, name, !negative);
  }
  
}