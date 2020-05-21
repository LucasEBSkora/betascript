import 'dart:io';
import 'bscFunction.dart';
import 'Number.dart';

bscFunction variable(String name, [bool negative = false]) => Variable._(name, negative);

class Variable extends bscFunction {
  
  final String name;

  Variable._(String this.name, [bool negative = false]) : super(negative);

  @override
  double call(Map<String, double> p) {
    if (!p.containsKey(name)) {
      print("Error! Missing arguments in call call: " + name + " not defined");
      exit(1);
    }
    return p[name]*factor;
  }

  @override
  bscFunction derivative(Variable v) {
    if (v.name == this.name) 
      return n(1).withSign(negative);
    else 
      return n(0);

  }

  @override
  String toString([bool handleMinus = true]) => ((handleMinus && negative) ? '-' : '') + name;

  @override
  bscFunction withSign(bool negative) => Variable._(name, negative);

}
