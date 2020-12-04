import 'dart:collection' show SplayTreeSet;

import 'package:meta/meta.dart';

import 'variable.dart';
import 'function.dart';

///This abstract class is used to improve code reutilization in function
///classes that have only one operand and are printed
///in the following way: name('operand'), where name is the class' name
abstract class SingleOperandFunction extends BSFunction {
  final BSFunction operand;

  @protected
  const SingleOperandFunction(this.operand, Set<Variable> params)
      : super(params);

  @override
  SplayTreeSet<Variable> get defaultParameters =>
      SplayTreeSet<Variable>.from(operand.parameters);

  // unfortunately can't define this one, because we must call the correct constructor
  // @override
  // BSFunction copy([bool negative, Set<Variable> params]);

}
