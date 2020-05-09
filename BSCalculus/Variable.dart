import 'dart:io';
import 'bscFunction.dart';
import 'Number.dart';

class Variable extends bscFunction {
  
  final String name;

  Variable(String this.name, [bool negative = false]) : super(negative);

  @override
  double evaluate(Map<String, double> p) {
    if (!p.containsKey(this)) {
      print("Error! Missing arguments in evaluate call: " + name + " not defined");
      exit(1);
    }
    return p[this];
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
