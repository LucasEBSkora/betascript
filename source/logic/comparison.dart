import 'dart:collection' show HashMap, SplayTreeSet;

import 'package:meta/meta.dart';

import 'logic_expression.dart';
import 'solvers/single_variable_solver.dart';
import '../sets/sets.dart';
import '../utils/three_valued_logic.dart';
import '../function/functions.dart';
import '../function/utils.dart';

///A class that represents an equation or inequality
abstract class Comparison extends LogicExpression {
  final BSFunction left;
  final BSFunction right;

  Comparison(this.left, this.right);

  bool compare(num _left, num _right);

  @protected
  String get type;

  BSLogical get alwaysTrue {
    final nums = toNums(left.approx, right.approx);

    //for now, if it can't convert both to numbers to make sure the comparison is always true, doesn't even try
    if (nums != null) {
      return BSLogical.fromBool(compare(nums.first, nums.second));
    }

    return bsUnknown;
  }

  ///checks if an expression is always false
  ///(so that comparisons between numbers aren't represented by trees
  ///when they could be a logical value)
  BSLogical get alwaysFalse {
    final nums = toNums(left.approx, right.approx);

    //for now, if it can't convert both to numbers to make sure the comparison is always false, doesn't even try
    //basically gets "alwaysTrue" and inverts it

    if (nums != null) {
      return BSLogical.fromBool(compare(nums.first, nums.second));
    }

    return bsUnknown;
  }

  ///checks if a set of values solves the expression
  ///if the variables passed aren't suficient to evaluate the expression,
  ///simply returns false instead of throwing
  BSLogical isSolution(HashMap<String, BSFunction> p) {
    BSFunction _left, _right;

    try {
      _left = left.evaluate(p).approx;
      _right = right.evaluate(p).approx;
    } on BetascriptFunctionError {
      return bsFalse;
    }

    final nums = toNums(_left, _right);

    if (nums != null) {
      return BSLogical.fromBool(compare(nums.first, nums.second));
    }

    return bsUnknown;
  }

  ///Check if a solution exists in the set (only for single variable expressions)
  BSLogical containsSolution(BSSet s) => bsUnknown;

  ///Check if every element in a set is a solution (only for single variable expressions)
  BSLogical everyElementIsSolution(BSSet s) => bsUnknown;

  ///a set with every solution ΒScript can find
  BSSet get solution {
    var solver = SingleVariableSolver(this);
    BSSet _sol = emptySet;
    if (solver.applies()) {
      _sol = solver.attemptSolve();
      _foundEverySolution = solver.everySolutionFound;
    }
    return (_sol == emptySet)
        ? BuilderSet(
            this, parameters.map((element) => variable(element)).toList())
        : _sol;
  }

  @override
  String toString() => "$left $type $right";

  SplayTreeSet<String> get parameters {
    final params = <Variable>{...left.parameters, ...right.parameters};
    return SplayTreeSet<String>.from(params.map((e) => e.name));
  }

  bool _foundEverySolution = false;
  //TODO: calling this without calling solution first will do dumb-dumb - VERY BAD. Also stops it from being const
  @override
  bool get foundEverySolution => _foundEverySolution;
}
