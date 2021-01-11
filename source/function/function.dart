import 'dart:collection' show HashMap, SplayTreeSet;

import 'package:meta/meta.dart';

import 'division.dart';
import 'exponentiation.dart';
import 'functions.dart';
import 'utils.dart';
import 'visitors/function_visitor.dart';
import 'multiplication.dart';
import 'negative.dart';
import 'sum.dart';
import 'variable.dart';
import 'visitors/partial_derivative.dart';
import 'visitors/plain_function_stringifier.dart';

abstract class BSFunction implements Comparable<BSFunction> {
  ///set of parameters the function is defined in ( the previous function NEEDS x, y and z to be evaluated, but we could define it in x,y,z and w if we wanted to)
  final Set<Variable> _parameters;

  ///Checks if the list of parameters passed is the correct length, creates a map containing the variables in the correct place by matching the params getter and this
  ///parameter.
  @nonVirtual
  BSFunction call(List<BSFunction> parametersList) {
    final _p = parameters;
    if (parametersList.length != _p.length) {
      throw BetascriptFunctionError(
          "Error! Missing parameters in function call!");
    }

    return evaluate(
        HashMap.fromIterables(parameters.map((e) => e.name), parametersList));
  }

  ///Returns the function with all possible aproximations made.
  BSFunction get approx;

  ///Returns the partial derivative of this in relation to [v]
  @nonVirtual
  BSFunction derivative(Variable v) =>
      _merge(accept<BSFunction>(PartialDerivative(v)), this);

  ///If there is a custom set of parameters, returns it. If there isn't, returns the default one
  @nonVirtual
  Set<Variable> get parameters => (_parameters ?? defaultParameters);

  ///Returns a copy of this function with the custom parameters passed in p, and checks if they include all needed parameters
  @nonVirtual
  BSFunction withParameters(Set<Variable> p) {
    final _p = defaultParameters;

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

  bool operator ==(Object other) =>
      (other is BSFunction) && toString() == other.toString();

  //very lazy but works
  int get hashCode => toString().hashCode;

  ///if the function can be evaluated with no variables, simplifies it as much as possible without any parameters.
  ///if it can't, returns [null]
  @nonVirtual
  BSFunction asConstant() {
    try {
      return evaluate(HashMap.from({}));
    } on BetascriptFunctionError {
      return null;
    }
  }

  ///if the function can be made constant, approximates it and turns it to a Dart num
  @nonVirtual
  num toNum() {
    final BSFunction _const = asConstant();
    if (_const == Constants.infinity) return double.infinity;
    if (_const == Constants.negativeInfinity) return double.negativeInfinity;
    if (_const == null) return null;
    final _approx = extractFromNegative<Number>(_const.approx);
    return (_approx.second) ? -_approx.first.value : _approx.first.value;
  }

  bool operator <=(BSFunction other) {
    final v = toNums(this, other, "<=");
    return v.first <= v.second;
  }

  bool operator <(BSFunction other) {
    final v = toNums(this, other, "<");
    return v.first < v.second;
  }

  bool operator >=(BSFunction other) {
    final v = toNums(this, other, ">=");
    return v.first >= v.second;
  }

  bool operator >(BSFunction other) {
    final v = toNums(this, other, ">");
    return v.first > v.second;
  }

  @protected
  const BSFunction(this._parameters);

  ///For internal use only! To actually evaluate, use call
  ///returns the value of this function when called with the parameters having the values in the map.
  /// Extra parameters should be ignored, but missing ones will cause a fatal error.
  ///Will always return an exact value, and it is not guaranteed to be as simplified as possible. This means that sin(0.5) will return Sin(0.5).
  ///for approximations, use the approx getter
  BSFunction evaluate(HashMap<String, BSFunction> p);

  @nonVirtual
  String toString() => accept<String>(PlainFunctionStringifier());

  ///returns the variables which this function actually needs to be evaluated ( e.g. (sin(x+y)*z).parameters returns [x, y, z]).
  ///It does, however, take into account custom parameters of its child functions
  @visibleForOverriding
  SplayTreeSet<Variable> get defaultParameters;

  ///Creates a copy of this function, but allows you to use different values for negative and _parameters.
  @visibleForOverriding
  BSFunction copy(Set<Variable> parameters);

  @override
  int compareTo(Object other) {
    if (other is BSFunction) {
      final nums = toNums(this, other);
      if (nums == null)
        throw BetascriptFunctionError(
            "$this and/or $other can't be converted to nums!");
      return nums.first.compareTo(nums.second);
    } else
      throw Exception("Can't compare Variable with ${other.runtimeType}!");
  }

  static BSFunction _merge(BSFunction source, BSFunction other) =>
      source.copy(other.parameters);

  T accept<T>(FunctionVisitor visitor);
}

class BetascriptFunctionError implements Exception {
  final String _message;

  BetascriptFunctionError(this._message);

  @override
  String toString() => _message;
}
