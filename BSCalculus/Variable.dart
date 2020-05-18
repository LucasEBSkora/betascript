import 'dart:io';
import 'bscFunction.dart';
import 'Number.dart';

class Variable extends bscFunction {
  
  final String name;

  Variable(String this.name, [bool negative = false]) : super(negative);

  @override
  double call(Map<String, double> p) {
    if (!p.containsKey(name)) {
      print("Error! Missing arguments in call call: " + name + " not defined");
      exit(1);
    }
    return p[name];
  }

  @override
  bscFunction derivative(Variable v) {
    if (v.name == this.name) 
      return Number(1).withSign(negative);
    else 
      return Number(0);

  }

  @override
  String toString([bool handleMinus = true]) => ((handleMinus && negative) ? '-' : '') + name;

  @override
  bscFunction withSign(bool negative) => Variable(name, negative);

}
