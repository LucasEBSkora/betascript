import 'dart:collection' show SplayTreeSet;
import 'package:meta/meta.dart';

import 'BSCalculus.dart';
import 'Multiplication.dart';
import 'Negative.dart';
import 'Sum.dart';
import 'Division.dart';
import 'Exponentiation.dart';
import 'Variable.dart';

import '../Utils/Tuples.dart';

import '../interpreter/BSCallable.dart';
import '../interpreter/BSInterpreter.dart';


abstract class BSFunction implements BSCallable {
  ///set of parameters the function is defined in ( the previous function NEEDS x, y and z to be evaluated, but we could define it in x,y,z and w if we wanted to)
  final Set<Variable> _parameters;

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

  //Returns the partial derivative of this in relation to v
  BSFunction derivative(Variable v) => _merge(this.derivative(v), this);

  //If there is a custom set of parameters, returns it. If there isn't, returns the default one
  Set<Variable> get parameters => (_parameters ?? defaultParameters);

  ///Returns a copy of this function with the custom parameters passed in p, and checks if they include all needed parameters
  BSFunction withParameters(Set<Variable> p) {
    Set<Variable> _p = defaultParameters;
    p.forEach((element) {
      if (!_p.contains(element))
        throw new BetascriptFunctionError(
            "Error! Function parameters not sufficient to evaluate this function!");
    });
    return copy(p);
  }

  BSFunction operator -() => negative(this);

  BSFunction operator +(BSFunction other) => add([this, other]);

  BSFunction operator -(BSFunction other) => add([this, -other]);

  BSFunction operator *(BSFunction other) => multiply([this, other]);

  BSFunction operator ^(BSFunction other) => exp(other, this);

  BSFunction operator /(BSFunction other) => divide([this], [other]);

  bool operator ==(dynamic other) =>
      (other is BSFunction) && toString() == other.toString();

  ///calculates the partial derivative of this in relation to v without merging. Is called by 'derivative', which also merges the
  ///functions
  @protected
  BSFunction derivativeInternal(Variable v);

  @protected
  const BSFunction(Set<Variable> this._parameters);

  ///For internal use only! To actually evaluate, use call
  ///returns the value of this function when called with the parameters having the values in the map.
  /// Extra parameters should be ignored, but missing ones will cause a fatal error.
  ///Will always return an exact value, and it is not guaranteed to be as simplified as possible. This means that sin(0.5) will return Sin(0.5).
  ///for approximations, use the approx getter
  @protected
  BSFunction evaluate(Map<String, BSFunction> p);

  String toString() => throw UnimplementedError();

  ///returns the variables which this function actually needs to be evaluated ( e.g. (sin(x+y)*z).parameters returns [x, y, z]).
  ///It does, however, take into account custom parameters of its child functions
  @protected
  SplayTreeSet<Variable> get defaultParameters;

  ///Creates a copy of this function, but allows you to use different values for negative and _parameters.
  @protected
  BSFunction copy(Set<Variable> parameters);

  static BSFunction _merge(BSFunction source, BSFunction other) =>
      source.copy(other.parameters);

  ///Checks if the function f is of Type 'type', or if it is of type Negative and its operand of type 'type'.
  ///if it manages to find something of the 'type', second is set to true.
  ///If it is contained inside a negative, third is set to true.
  static Trio<T, bool, bool> extractFromNegative<T extends BSFunction>(
      BSFunction f) {
    bool _isInNegative = false;
    if (f is Negative) {
      f = (f as Negative).operand;
      _isInNegative = true;
    }

    return Trio((f is T) ? f : null, f is T, _isInNegative);
  }

  @override
  int get arity => parameters.length;

  
  Object callThing(BSInterpreter interpreter, List<Object> arguments) => call(arguments);

}

class BetascriptFunctionError implements Exception {
  final String _message;

  BetascriptFunctionError(this._message);

  @override
  String toString() => _message;
}
