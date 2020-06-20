import 'dart:collection' show SplayTreeSet;

import 'BSCalculus.dart';
import 'Multiplication.dart';
import 'Sum.dart';
import 'Division.dart';
import 'Exponentiation.dart';
import 'Variable.dart';

abstract class BSFunction {
  ///whether this function is multiplied by -1, basically.
  final bool negative;

  const BSFunction(bool this.negative, Set<Variable> this._parameters);

  ///For internal use only! To actually evaluate, use call
  ///returns the value of this function when called with the parameters having the values in the map.
  /// Extra parameters should be ignored, but missing ones will cause a fatal error.
  ///Will always return an exact value, and it is not guaranteed to be as simplified as possible. This means that sin(0.5) will return Sin(0.5).
  ///for approximations, use the approx getter
  BSFunction evaluate(Map<String, BSFunction> p);

  ///Checks if the list of parameters passed is the correct length, creates a map containing the variables in the correct place by matching the params getter and this
  ///parameter.
  BSFunction call(List<BSFunction> parameters) {
    Set<Variable> _p = this.parameters;
    if (parameters.length != _p.length)
      throw new BetascriptFunctionError(
          "Error! Missing parameters in function call!");

    return evaluate(
        Map.fromIterables(this.parameters.map((e) => e.name), parameters));
  }

  ///Returns the function with all possible aproximations made.
  BSFunction get approx;

  ///Returns the partial derivative of this in relation to v
  BSFunction derivative(Variable v);

  /// whether or not the function itself should print a minus sign before it (if applicable), because the Sum class, which is used to implement sums and subtractions, uses it.
  String toString([bool handleMinus = true]);

  ///Creates a copy of this function, but allows you to use different values for negative and _parameters.
  BSFunction copy([bool negative, Set<Variable> parameters = null]);

  /// Returns this function multiplied by -1
  BSFunction get opposite => copy(!negative);

  /// Returns this function with negative as false
  BSFunction get ignoreNegative => copy(false);

  ///if invert is true, returns this function with the opposite sign. Used to factor in the function sign when doing derivatives, but has little practical use elsewhere.
  BSFunction invertSign(bool invert) => copy((invert) ? !negative : negative);

  ///A getter to replace a very overused ternary operator, normally used in call()
  num get factor => (negative ? -1 : 1);

  ///Same thing for toString()
  String minusSign(bool handleMinus) => ((handleMinus && negative) ? '-' : '');

  ///returns the variables which this function actually needs to be evaluated ( e.g. (sin(x+y)*z).parameters returns [x, y, z]).
  SplayTreeSet<Variable> get minParameters;


  ///set of parameters the function is defined in ( the previous function NEEDS x, y and z to be evaluated, but we could define it in x,y,z and w if we wanted to)
  final Set<Variable> _parameters;

  //If there is a custom set of parameters, returns it. If there isn't, returns the default one
  Set<Variable> get parameters => (_parameters ?? minParameters);

  //Returns a copy of this function with the
  BSFunction withParameters(Set<Variable> p) {
    Set<Variable> _p = minParameters;
    p.forEach((element) {
      if (!_p.contains(element))
        throw new BetascriptFunctionError(
            "Error! Function parameters not sufficient to evaluate this function!");
    });
    return copy(negative, p);
  }

  BSFunction operator -() => this.opposite;

  BSFunction operator +(BSFunction other) => add([this, other]);

  BSFunction operator -(BSFunction other) => add([this, -other]);

  BSFunction operator *(BSFunction other) => multiply([this, other]);

  BSFunction operator ^(BSFunction other) => exp(other, this);

  BSFunction operator /(BSFunction other) => divide([this], [other]);

  bool operator ==(dynamic other) =>
      (other is BSFunction) && toString() == other.toString();
}

class BetascriptFunctionError implements Exception {
  final String _message;

  BetascriptFunctionError(this._message);

  @override
  String toString() => _message;
}
