import 'BSCalculus.dart';
import 'Multiplication.dart';
import 'Sum.dart';
import 'Division.dart';
import 'Exponentiation.dart';
import 'Variable.dart';

abstract class BSFunction {

  ///whether this function is multiplied by -1, basically.
  final bool negative;

  const BSFunction ([bool this.negative = false]);

  ///returns the value of this function when called with the parameters having the values in the map. Extra parameters should be ignored, but missing ones will cause a fatal error.
  ///Will always return an exact value, and it is not guaranteed to be as simplified as possible. This means that sin(0.5) will return Sin(0.5).
  ///for approximations, use the approx getter
  BSFunction call(Map<String, BSFunction> p); 

  ///Returns the function with all possible aproximations made. 
  BSFunction get approx;

  ///Returns the partial derivative of this in relation to v
  BSFunction derivative(Variable v);
  
  /// whether or not the function itself should print a minus sign before it (if applicable), because the Sum class, which is used to implement sums and subtractions, uses it.
  String toString([bool handleMinus = true]);
  
  /// Returns this function multiplied by -1
  BSFunction get opposite => withSign(!negative);

  /// Returns this function with negative as false
  BSFunction get ignoreNegative => withSign(false);

  ///if invert is true, returns this function with the opposite sign. Used to factor in the function sign when doing derivatives, but has little practical use elsewhere.
  BSFunction invertSign(bool invert) => withSign((invert) ? !negative : negative);
  
  BSFunction withSign(bool negative);


  ///A getter to replace a very overused ternary operator, normally used in call()
  num get factor => (negative ? -1 : 1);

  ///Same thing for toString()
  String minusSign(bool handleMinus) => ((handleMinus && negative) ? '-' : '');

  ///returns the variables in which this function is defined ( e.g. (sin(x+y)*z).parameters returns [x, y, z])
  Set<Variable> get parameters;

  BSFunction operator -() => this.opposite;

  BSFunction operator +(BSFunction other) => add([this, other]);

  BSFunction operator -(BSFunction other) => add([this, -other]);

  BSFunction operator *(BSFunction other) => multiply([this, other]);

  BSFunction operator ^(BSFunction other) => exp(other, this);

  BSFunction operator /(BSFunction other) => divide([this], [other]);

  bool operator ==(dynamic other) => (other is BSFunction) && toString() == other.toString();

}