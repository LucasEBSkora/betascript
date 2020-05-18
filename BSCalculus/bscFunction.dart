import 'BSCalculus.dart';
import 'Multiplication.dart';
import 'Sum.dart';
import 'Division.dart';
import 'Exponentiation.dart';

abstract class bscFunction {
  
  ///whether this function is multiplied by -1, basically.
  final bool negative;

  const bscFunction ([bool this.negative = false]);

  ///returns the value of this function when called with the parameters having the values in the map. Extra parameters should be ignored, but missing ones will cause a fatal error.
  num call(Map<String, double> p); 

  ///Returns the partial derivative of this in relation to v
  bscFunction derivative(Variable v);
  
  /// whether or not the function itself should print a minus sign before it (if applicable), because the Sum class, which is used to implement sums and subtractions, uses it.
  String toString([bool handleMinus = true]);
  
  /// Returns this function multiplied by -1
  bscFunction get opposite => withSign(!negative);

  /// Returns this function with negative as false
  bscFunction get ignoreNegative => withSign(false);

  ///if invert is true, returns this function with the opposite sign. Used to factor in the function sign when doing derivatives, but has little practical use elsewhere.
  bscFunction invertSign(bool invert) => withSign((invert) ? !negative : negative);
  
  bscFunction withSign(bool negative);


  bscFunction operator -() => this.opposite;

  bscFunction operator +(bscFunction other) => Sum.create([this, other]);

  bscFunction operator -(bscFunction other) => Sum.create([this, -other]);

  bscFunction operator *(bscFunction other) => Multiplication.create([this, other]);

  bscFunction operator ^(bscFunction other) => Exponentiation.create(other, this);

  bscFunction operator /(bscFunction other) => Division.create([this], [other]);

  bool operator ==(dynamic other) => (other is bscFunction) && toString() == other.toString();

}