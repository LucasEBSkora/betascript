import 'dart:io';
import 'bscFunction.dart';
import 'Number.dart';

class Variable extends bscFunction {
  
  final String _name;

  Variable(String this._name, [bool negative = false]) : super(negative);

  @override
  double evaluate(Map<String, double> p) {
    if (!p.containsKey(this)) {
      print("Error! Missing arguments in evaluate call: " + _name + " not defined");
      exit(1);
    }
    return p[this];
  }

  @override
  bscFunction derivative(Variable v) {
    if (v._name == this._name) 
      return Number(1);
    else 
      return Number(0);

  }

  @override
  String toString([bool handleMinus = true]) {
    return 
      (handleMinus && negative) ? '-' : '' +
      _name;
  }

  @override
  bscFunction ignoreNegative() {
    return Variable(_name, false);
  }

  @override
  bscFunction opposite() {
    return Variable(_name, !negative);
  }

}
