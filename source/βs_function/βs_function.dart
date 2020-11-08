import 'dart:collection' show HashMap, SplayTreeSet;

import 'package:meta/meta.dart';

import 'division.dart';
import 'exponentiation.dart';
import 'multiplication.dart';
import 'negative.dart';
import 'number.dart';
import 'sum.dart';
import 'variable.dart';
import 'βs_calculus.dart';
import '../interpreter/βs_callable.dart';
import '../interpreter/βs_interpreter.dart';
import '../utils/tuples.dart';

abstract class BSFunction implements BSCallable {
  ///set of parameters the function is defined in ( the previous function NEEDS x, y and z to be evaluated, but we could define it in x,y,z and w if we wanted to)
  final Set<Variable> _parameters;

  ///Checks if the list of parameters passed is the correct length, creates a map containing the variables in the correct place by matching the params getter and this
  ///parameter.
  BSFunction call(List<BSFunction> parametersList) {
    Set<Variable> _p = parameters;
    if (parametersList.length != _p.length) {
      throw BetascriptFunctionError(
          "Error! Missing parameters in function call!");
    }

    return evaluate(
        HashMap.fromIterables(parameters.map((e) => e.name), parametersList));
  }

  ///Returns the function with all possible aproximations made.
  BSFunction get approx;

  //Returns the partial derivative of this in relation to v
  BSFunction derivative(Variable v) => _merge(derivativeInternal(v), this);

  ///If there is a custom set of parameters, returns it. If there isn't, returns the default one
  Set<Variable> get parameters => (_parameters ?? defaultParameters);

  ///Returns a copy of this function with the custom parameters passed in p, and checks if they include all needed parameters
  BSFunction withParameters(Set<Variable> p) {
    Set<Variable> _p = defaultParameters;

    for (var element in _p) {
      if (!p.contains(element)) {
        throw BetascriptFunctionError(
            "Error! Function parameters not sufficient to evaluate this function!");
      }
    }
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

  static Pair<num, num> toNums(BSFunction a, BSFunction b, [String op]) {
    Trio<Number, bool, bool> _a = BSFunction.extractFromNegative<Number>(a);
    Trio<Number, bool, bool> _b = BSFunction.extractFromNegative<Number>(b);
    if (!_a.second || !_b.second) {
      if (op != null) {
        throw BetascriptFunctionError(
            "operand $op can only be used on numbers");
      } else {
        return Pair(null, null);
      }
    }

    return Pair<num, num>(((_a.third) ? -1 : 1) * _a.first.value,
        ((_b.third) ? -1 : 1) * _b.first.value);
  }

  bool operator <=(BSFunction other) {
    Pair<num, num> v = toNums(this, other, "<=");
    return v.first <= v.second;
  }

  bool operator <(BSFunction other) {
    Pair<num, num> v = toNums(this, other, "<");
    return v.first < v.second;
  }

  bool operator >=(BSFunction other) {
    Pair<num, num> v = toNums(this, other, ">=");
    return v.first >= v.second;
  }

  bool operator >(BSFunction other) {
    Pair<num, num> v = toNums(this, other, ">");
    return v.first > v.second;
  }

  static min(BSFunction x, BSFunction y) {
    Pair<num, num> v = toNums(x, y, "min");
    return (v.first < v.second) ? x : y;
  }

  static max(BSFunction x, BSFunction y) {
    Pair<num, num> v = toNums(x, y, "max");
    return (v.first > v.second) ? x : y;
  }

  ///calculates the partial derivative of this in relation to v without merging.
  ///Is called by 'derivative', which also merges the functions.
  @visibleForOverriding
  BSFunction derivativeInternal(Variable v);

  @protected
  const BSFunction(this._parameters);

  ///For internal use only! To actually evaluate, use call
  ///returns the value of this function when called with the parameters having the values in the map.
  /// Extra parameters should be ignored, but missing ones will cause a fatal error.
  ///Will always return an exact value, and it is not guaranteed to be as simplified as possible. This means that sin(0.5) will return Sin(0.5).
  ///for approximations, use the approx getter
  BSFunction evaluate(HashMap<String, BSFunction> p);

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

  //Doesn't check if the cast is succesful because it assumes the interpreter did its job
  Object callThing(BSInterpreter interpreter, List<Object> arguments) =>
      call(arguments.map((object) => object as BSFunction).toList());
}

class BetascriptFunctionError implements Exception {
  final String _message;

  BetascriptFunctionError(this._message);

  @override
  String toString() => _message;
}
