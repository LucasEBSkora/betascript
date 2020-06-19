import 'dart:io';
import 'BSFunction.dart';
import 'Number.dart';

BSFunction variable(String name, [bool negative = false]) => Variable._(name, negative);

class Variable extends BSFunction {
  
  final String name;

  Variable._(String this.name, [bool negative = false]) : super(negative);

  @override
  BSFunction call(Map<String, BSFunction> p) {
    if (!p.containsKey(name)) {
      print("Error! Missing arguments in call call: " + name + " not defined");
      exit(1);
    }
    return p[name].withSign(negative);
  }

  @override
  BSFunction derivative(Variable v) {
    if (v.name == this.name) 
      return n(1).withSign(negative);
    else 
      return n(0);

  }

  @override
  String toString([bool handleMinus = true]) => minusSign(handleMinus) + name;

  @override
  BSFunction withSign(bool negative) => Variable._(name, negative);

  @override
  Set<Variable> get parameters => Set.from([this]);

  @override
  BSFunction get approx => this;

}
