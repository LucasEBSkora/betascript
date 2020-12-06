import 'solver.dart';
import '../logic.dart';
import '../../sets/sets.dart';
import '../../function/function.dart';
import '../../function/multiplication.dart';
import '../../function/negative.dart';
import '../../function/number.dart';
import '../../function/sum.dart';
import '../../function/utils.dart';
import '../../function/variable.dart';

//in the context of this program, ?= means ==, !=, <, >, <= or >=

class SingleVariableLinearSolver extends Solver {
  Comparison _comp;
  BSFunction _left;

  //as in, ax + b ?= 0
  BSFunction a = n(0);
  BSFunction b = n(0);
  //keeps note of whether we multiplied the comparison by -1, because that inverts inequations
  bool invertedInequality = false;

  SingleVariableLinearSolver(LogicExpression expr) : super(expr);

  @override
  bool appliesInternal() {
    //we're sure that the expression only uses one variable because it was checked in SingleVariableSolver
    if (expr is Comparison) {
      //f(x) ?= g(x)
      _comp = expr;
      //"passes" everything to the left side of the equation
      _left = _comp.left - _comp.right;
      //f(x) - g(x) ?= 0
      //if possible/necessary, gets rid of a minus sign, but keeps it saved in case the comparison is a inequation
      if (_left is Negative) {
        invertedInequality = true;
        _left = (_left as Negative).operand;
      }
      final _terms = <BSFunction>[];
      //if the function is a sum, separates it into terms to check if all of them are linear
      if (_left is Sum) {
        _terms.addAll((_left as Sum).operands);
      } else {
        //if it isn't, checks that single term
        _terms.add(_left);
      }

      //checks if all terms are linear, and calculates the coefficients when they are. If all terms are linear, the solver applies
      return _terms.fold(
          true,
          (previousValue, element) =>
              previousValue && _extractCoefficients(element));
    }

    return false;
  }

  //In checking if the comparison applies, we already determined the coefficents, so we really only have to check which type of comparison it is
  @override
  BSSet attemptSolveInternal() {
    //we now split it in two cases: a == 0 and a =/= 0.
    if (a == n(0)) {
      //in this case, the value of the variable doesn't matter, which means any value solves it or no value solves it

      if ((expr as Comparison).compare(b.toNum(), 0)) {
        return BSSet.R;
      } else {
        return emptySet;
      }
    } else {
      //we rewrite the comparison as x ?= -b/a, remembering that if a < 0, then we must invert the inequation
      final aWithoutNegative = extractFromNegative(a);
      if (aWithoutNegative.second) invertedInequality = !invertedInequality;
      final val = -b / aWithoutNegative.first;
      if (_comp is Equal) return rosterSet([val]);
      if (_comp is NotEqual) {
        return SetUnion([
          Interval.open(Constants.negativeInfinity, val),
          Interval.open(val, Constants.infinity)
        ]);
      }
      if ((_comp is LessThan && !invertedInequality) ||
          (_comp is GreaterThan && invertedInequality)) {
        return Interval.open(Constants.negativeInfinity, val);
      }

      if ((_comp is GreaterThan && !invertedInequality) ||
          (_comp is LessThan && invertedInequality)) {
        return Interval.open(val, Constants.infinity);
      }

      if ((_comp is LessOrEqual && !invertedInequality) ||
          (_comp is GreaterOrEqual && invertedInequality)) {
        return Interval(Constants.negativeInfinity, val, false, true);
      }

      if ((_comp is GreaterOrEqual && !invertedInequality) ||
          (_comp is LessOrEqual && invertedInequality)) {
        return Interval(val, Constants.infinity, true, false);
      }
    }

    return emptySet;
  }

  bool _extractCoefficients(BSFunction term) {
    final _asNumber = term.asConstant();
    //if it's a constant, adds it to 'b'
    if (_asNumber != null) {
      b += _asNumber;
      return true;
    }

    final _asVar = extractFromNegative<Variable>(term);

    if (_asVar.first != null) {
      a += n(1);
      return true;
    }

    //if it got here, we already know the multiplication isn't constant, so there is at least one term that involves the variable
    final _asMul = extractFromNegative<Multiplication>(term);

    if (_asMul.first != null) {
      final constants = <BSFunction>[];
      final dependentTerms = <BSFunction>[];

      for (var op in _asMul.first.operands) {
        final constOp = op.asConstant();
        if (constOp != null) {
          constants.add(constOp);
        } else {
          dependentTerms.add(op);
        }
      }
      final dependentTerm =
          extractFromNegative<Variable>(multiply(dependentTerms));
      if (dependentTerm.first == null) {
        return false;
      } else {
        a += multiply(constants);
        return true;
      }
    }

    return false;
  }

  //we can always get every exact solution for this type of comparison
  @override
  bool get everySolutionFound => true;
}
