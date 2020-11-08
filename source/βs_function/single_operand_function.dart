import 'dart:collection' show SplayTreeSet;

import 'variable.dart';
import 'βs_function.dart';

///This abstract class is used to improve code reutilization in function 
///classes that have only one operand and are printed
///in the following way: name('operand'), where name is the class' name
abstract class singleOperandFunction extends BSFunction {
  final BSFunction operand;

  const singleOperandFunction(this.operand, Set<Variable> params)
      : super(params);

  //assumes the class name matches the function name, ignoring camel case
  @override
  String toString() =>
      "${runtimeType.toString().toLowerCase()}($operand)";

  @override
  SplayTreeSet<Variable> get defaultParameters => operand.parameters;

  //can't define the following, since they actually depend on the function.

  // @override
  // BSFunction derivativeInternal(Variable v);
  // @override
  // BSFunction evaluate(HashMap<String, BSFunction> p);

  // unfortunately can't define this one either, because we must call the correct constructor
  // @override
  // BSFunction copy([bool negative, Set<Variable> params]);

}
