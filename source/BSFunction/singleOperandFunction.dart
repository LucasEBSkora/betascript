import 'Variable.dart';
import 'bscFunction.dart';

///This abstract class is used to improve code reutilization in function classes that have only one operand and are printed
///in the following way: name('operand'), where name is the class' name
abstract class singleOperandFunction extends bscFunction {
  final bscFunction operand;

  singleOperandFunction(bscFunction this.operand, [bool negative = false]) : super(negative);

  //assumes the class name matches the function name, ignoring camel case
  @override
  String toString([bool handleMinus = true]) =>
      "${minusSign(handleMinus)}${runtimeType.toString().toLowerCase()}($operand)";

  @override
  Set<Variable> get parameters => operand.parameters;

  //can't define the following, since they actually depend on the function.

  // @override
  // bscFunction derivative(Variable v);
  // @override
  // num call(Map<String, double> p);

  // unfortunately can't define this one either, because we must call the correct constructor
  // @override
  // bscFunction withSign(bool negative);


}