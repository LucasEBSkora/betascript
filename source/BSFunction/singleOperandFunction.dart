import 'Variable.dart';
import 'BSFunction.dart';

///This abstract class is used to improve code reutilization in function classes that have only one operand and are printed
///in the following way: name('operand'), where name is the class' name
abstract class singleOperandFunction extends BSFunction {
  final BSFunction operand;

  singleOperandFunction(BSFunction this.operand, [bool negative = false]) : super(negative);

  //assumes the class name matches the function name, ignoring camel case
  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}${runtimeType.toString().toLowerCase()}($operand)";

  @override
  Set<Variable> get parameters => operand.parameters;

  //can't define the following, since they actually depend on the function.

  // @override
  // BSFunction derivative(Variable v);
  // @override
  // BSFunction call(Map<String, BSFunction> p);

  // unfortunately can't define this one either, because we must call the correct constructor
  // @override
  // BSFunction withSign(bool negative);


}