import 'solver.dart';
import '../logic/logic.dart';
import '../sets/sets.dart';
import '../βs_function/multiplication.dart';
import '../βs_function/negative.dart';
import '../βs_function/number.dart';
import '../βs_function/sum.dart';
import '../βs_function/variable.dart';
import '../βs_function/βs_function.dart';

//in the context of this program, ?= means ==, !=, <, >, <= or >=

class SingleVariableLinearSolver extends Solver {
  Comparison _comp;
  BSFunction _left;

  //as in, ax + b ?= 0
  num a = 0;
  num b = 0;
  //keeps note of whether we multiplied the comparison by -1, because that inverts inequations
  bool invertedInequality = false;

  SingleVariableLinearSolver(LogicExpression expr) : super(expr);

  @override
  bool appliesInternal() {
    if (expr.parameters.length == 1) {
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
        List<BSFunction> _terms = <BSFunction>[];
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
                previousValue && extractCoefficients(element));
      }
    }

    return false;
  }

  //In checking if the comparison applies, we already determined the coefficents, so we really only have to check which type of comparison it is
  @override
  BSSet attemptSolveInternal() {
    //we now split it in two cases: a == 0 and a =/= 0.
    if (a == 0) {
      //in this case, the value of the variable doesn't matter, which means any value solves it or no value solves it

      if ((expr as Comparison).compare(b, 0)) {
        return BSSet.R;
      } else {
        return emptySet;
      }
    } else {
      //we rewrite the comparison as x ?= -b/a, remembering that if a < 0, then we must invert the inequation
      if (a < 0) invertedInequality = !invertedInequality;
      BSFunction val = n(-b / a);
      if (_comp is Equal) return rosterSet([val]);
      if (_comp is NotEqual) {
        return SetUnion([
          Interval.open(constants.negativeInfinity, val),
          Interval.open(val, constants.infinity)
        ]);
      }
      if ((_comp is LessThan && !invertedInequality) ||
          (_comp is GreaterThan && invertedInequality)) {
        return Interval.open(constants.negativeInfinity, val);
      }

      if ((_comp is GreaterThan && !invertedInequality) ||
          (_comp is LessThan && invertedInequality)) {
        return Interval.open(val, constants.infinity);
      }

      if ((_comp is LessOrEqual && !invertedInequality) ||
          (_comp is GreaterOrEqual && invertedInequality)) {
        return Interval(constants.negativeInfinity, val, false, true);
      }

      if ((_comp is GreaterOrEqual && !invertedInequality) ||
          (_comp is LessOrEqual && invertedInequality)) {
        return Interval(val, constants.infinity, true, false);
      }
    }

    return emptySet;
  }

  bool extractCoefficients(BSFunction term) {
    var _asNumber = BSFunction.extractFromNegative<Number>(term);
    //if it's a number, adds it to 'b'
    if (_asNumber.second) {
      if (_asNumber.third) {
        b -= _asNumber.first.value;
      } else {
        b += _asNumber.first.value;
      }

      return true;
    }

    var _asVar = BSFunction.extractFromNegative<Variable>(term);

    if (_asVar.second) {
      if (_asNumber.third) {
        a -= 1;
      } else {
        a += 1;
      }
      return true;
    }

    var _asMul = BSFunction.extractFromNegative<Multiplication>(term);

    //since multiplications are guaranteed to have at least two terms, and any constants in them to be in the first term,
    //we can simply check that the first operand is a number and the second a variable
    //(which we know is the one we're using because we already checked the function is defined in a single variable)
    if (_asMul.second) {
      List<BSFunction> op = _asMul.first.operands;
      if (op.length == 2 && op.first is Number && op.last is Variable) {
        if (_asMul.third) {
          a -= (op.first as Number).value;
        } else {
          a += (op.first as Number).value;
        }
        return true;
      }
    }

    return false;
  }

  //we can always get every exact solution for this type of comparison
  @override
  bool get EverySolutionFound => true;
}
