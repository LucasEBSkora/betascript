import 'dart:collection' show HashMap, SplayTreeSet;
import 'package:meta/meta.dart';

import '../βs_function/βs_calculus.dart';
import '../sets/sets.dart';
import 'logic_expression.dart';
import '../utils/tuples.dart';

import '../solvers/single_variable_solver.dart';

///A class that represents an equation or inequality
abstract class Comparison extends LogicExpression {
  final BSFunction left;
  final BSFunction right;
  Comparison(this.left, this.right);

  bool compare(num _left, num _right);

  @protected
  String get type;

  bool get alwaysTrue {
    BSFunction _left = left.approx;
    BSFunction _right = right.approx;

    Pair<num, num> nums = BSFunction.toNums(_left, _right);

    //for now, if it can't convert both to numbers to make sure the comparison is always true, doesn't even try
    if (nums.first != null) {
      compare(nums.first, nums.second);
    }

    return false;
  }

  ///checks if an expression is always false(so that comparisons between numbers aren't represented by trees when they could be a boolean)
  bool get alwaysFalse {
    BSFunction _left = left.approx;
    BSFunction _right = right.approx;

    Pair<num, num> nums = BSFunction.toNums(_left, _right);

    //for now, if it can't convert both to numbers to make sure the comparison is always false, doesn't even try
    //basically gets "alwaysTrue" and inverts it

    if (nums.first != null) {
      return compare(nums.first, nums.second);
    }

    return false;
  }

  ///checks if a set of values solves the expression
  ///if the variables passed aren't suficient to evaluate the expression, simply returns false instead of throwing
  bool isSolution(HashMap<String, BSFunction> p) {
    BSFunction _left = null, _right = null;

    try {
      _left = left.evaluate(p).approx;
      _right = right.evaluate(p).approx;
    } on BetascriptFunctionError {
      return false;
    }

    Pair<num, num> nums = BSFunction.toNums(_left, _right);

    if (nums.first != null) {
      return compare(nums.first, nums.second);
    }

    return false;
  }

  ///Check if a solution exists in the set (only for single variable expressions)
  bool containsSolution(BSSet s) => false;

  ///Check if every element in a set is a solution (only for single variable expressions)
  bool everyElementIsSolution(BSSet s) => false;

  ///returns a set with every solution betascript can find
  BSSet get solution {
    var solver = SingleVariableSolver(this);
    BSSet _sol = emptySet;
    if (solver.applies()) {
      _sol = solver.attemptSolve();
      _foundEverySolution = solver.EverySolutionFound;
    }
    return (_sol == emptySet) ? BuilderSet(this, this.parameters.map((element) => variable(element)).toList()) : _sol;
  }

  @override
  String toString() => "$left $type $right";

  SplayTreeSet<String> get parameters {
    Set<Variable> params = left.parameters;
    params.addAll(right.parameters);
    return SplayTreeSet.from(params.map((e) => e.name));
  }

  bool _foundEverySolution = false;
  //TODO: calling this without calling solution first will do dumb-dumb - VERY BAD
  @override
  bool get foundEverySolution => _foundEverySolution;
}
