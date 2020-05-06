import 'BSCalculus.dart';
import 'Multiplication.dart';
import 'Sum.dart';

abstract class bscFunction {
  
  ///whether this function is multiplied by -1, basically.
  final bool negative;

  const bscFunction ([bool this.negative = false]);


  ///returns the value of this function when called with the parameters having the values in the map. Extra parameters should be ignored, but missing ones will cause a fatal error.
  num evaluate(Map<String, double> p); 

  ///Returns the partial derivative of this in relation to v
  bscFunction derivative(Variable v);
  
  /// whether or not the function itself should print a minus sign before it (if applicable), because the Sum class, which is used to implement sums and subtractions, uses it.
  String toString([bool handleMinus = true]);
  
  /// Returns this function multiplied by -1
  bscFunction opposite();

  /// Returns this function with negative as false
  bscFunction ignoreNegative();


  bscFunction operator +(bscFunction other) {
    return Sum.create([this, other]);
  }

  bscFunction operator *(bscFunction other) {
    return Multiplication.create([this, other]);
  }

  bscFunction operator -() {
    return this.opposite();
  }

}


