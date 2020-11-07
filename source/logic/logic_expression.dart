import 'dart:collection' show HashMap, SplayTreeSet;

import '../sets/sets.dart';
import '../βs_function/βs_calculus.dart';

///A class used to REPRESENT a logic expression and to check if a set of values solves it, but not necessarily to solve them
abstract class LogicExpression {
  //Remember that betascript follows a "false negatives over false positives": if betascript isn't sure, it will say no, and only say yes when absolutely sure

  ///checks if an expression is always true (so that comparisons between numbers aren't represented by trees when they could be a boolean)
  bool get alwaysTrue => false;

  ///checks if an expression is always false(so that comparisons between numbers aren't represented by trees when they could be a boolean)
  bool get alwaysFalse => false;

  ///checks if a set of values solves the expression
  bool isSolution(HashMap<String, BSFunction> p) => false;

  ///Check if a solution exists in the set (only for single variable expressions)
  bool containsSolution(BSSet s) => false;

  ///Check if every element in a set is a solution (only for single variable expressions)
  bool everyElementIsSolution(BSSet s) => false;

  ///returns a set with every solution betascript can find
  BSSet get solution => emptySet;

  SplayTreeSet<String> get parameters;

  bool get foundEverySolution;
}
