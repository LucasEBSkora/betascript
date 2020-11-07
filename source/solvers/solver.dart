import 'package:meta/meta.dart';

import '../sets/sets.dart';
import '../logic/logic.dart';

abstract class Solver {
  final LogicExpression expr;
  @protected
  bool doesApply = false;

  Solver(this.expr);

  //returns whether we're sure that every solution to the expression is found
  bool get EverySolutionFound;

  ///Tries to solve the expression. If it can't find any solutions, returns an empty set.
  BSSet attemptSolve() => (doesApply)
      ? attemptSolveInternal()
      : throw BetascriptSolverError(
          "this type of solver does not apply to this expression", expr);

  ///Checks if an expression is of the type this solver is made for.
  bool applies() {
    doesApply = appliesInternal();
    return doesApply;
  }

  @protected
  BSSet attemptSolveInternal();

  @protected
  bool appliesInternal();
}

class BetascriptSolverError implements Exception {
  final String message;
  final LogicExpression expression;
  BetascriptSolverError(this.message, this.expression);

  @override
  String toString() => "Error: $message with expression '$expression'";
}
