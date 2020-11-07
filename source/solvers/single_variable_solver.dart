import 'single_variable_linear_solver.dart';
import 'solver.dart';
import '../logic/logic.dart';
import '../sets/sets.dart';

class SingleVariableSolver extends Solver {
  bool _everySolutionFound = false;
  SingleVariableSolver(LogicExpression expr) : super(expr);

  @override
  bool appliesInternal() => expr.parameters.length == 1;

  @override
  BSSet attemptSolveInternal() {
    BSSet solution = emptySet;
    SingleVariableLinearSolver s1 = SingleVariableLinearSolver(expr);
    if (s1.applies()) {
      solution = s1.attemptSolve();
      _everySolutionFound = s1.EverySolutionFound;
    }
    return solution;
  }

  @override
  bool get EverySolutionFound => _everySolutionFound;
}
