import 'Number.dart';
import 'Sum.dart';
import 'Utils/Pair.dart';
import 'bscFunction.dart';
import 'Variable.dart';

class Multiplication extends bscFunction {
  final List<bscFunction> operands;

  Multiplication._(List<bscFunction> this.operands, [bool negative = false])
      : super(negative);

  static bscFunction create(List<bscFunction> operands) {
    if (operands == null || operands.length == 0) return(Number(0));

    _openOtherMultiplcations(operands);
    bool negativeForNumbers = _multiplyNumbers(operands);
    bool negativeOthers = _consolidateNegatives(operands);

    bool negative = (negativeForNumbers && !negativeOthers) || (!negativeForNumbers && negativeOthers);


    if(operands.length == 0) return Number(0);
    if(operands.length == 1) return operands[0].withSign(negative);
    else return Multiplication._(operands, negative);
  }

  static void _openOtherMultiplcations(List<bscFunction> operands) {
    int i = 0;
    while (i < operands.length) {
      if (operands[i] is Multiplication) {
        Multiplication m = operands.removeAt(i);
        operands.insertAll(i, m.operands);
        if (m.negative) operands.add(Number(-1));
      } else
        ++i;
    }
  }

  ///Returns the value of "negative"
  static bool _multiplyNumbers(List<bscFunction> operands) {
    double number = 1;
    bool negative = false;

    Map<String, Pair<double, int>> namedNumbers =
        Map<String, Pair<double, int>>();

    int i = 0;
    while (i < operands.length) {
      if (operands[i] is Number) {
        Number n = operands.removeAt(i);
        if (!n.isNamed)
          number *= n.value;
        else {
        
          if (!namedNumbers.containsKey(n.name))
            namedNumbers[n.name] = Pair<double, int>(n.absvalue, 0);

          ++namedNumbers[n.name].second;
        
          if (n.negative) number *= -1;
        }
      } else
        ++i;
    }

    if (number == 0) operands.clear();
    else {

      List<bscFunction> numbers = List<bscFunction>();
      if (number < 0) negative = true;
      if (number.abs() != 1) numbers.add(Number(number.abs()));

      for (String key in namedNumbers.keys) {
        if (namedNumbers[key].second != 0)
          numbers.add(Number.named(namedNumbers[key].first, key) ^ Number(namedNumbers[key].second));
      }

      operands.insertAll(0, numbers);
    }

    return negative;
  }

  static bool _consolidateNegatives(List<bscFunction> operands) {
    bool negative = false;
    
    
    List<bscFunction> newOperands = operands.map((bscFunction f) {
      if (f.negative) negative = !negative;
      return f.ignoreNegative;
    }).toList();

    operands.clear();
    operands.insertAll(0, newOperands);

    return negative;
  }

  @override
  bscFunction derivative(Variable v) {
    List<bscFunction> ops = List<bscFunction>();

    for (int i = 0; i < operands.length; ++i) {
      
      //copies list
      List<bscFunction> term = [...operands];
      
      //removes "current" operand (which isn't derivated)
      bscFunction current = term.removeAt(i);

      //Derivates the others
      List<bscFunction> termExpression = term.map((f) {
        return f.derivative(v);
      }).toList();

      //includes the current element again
      termExpression.insert(i, current);

      //adds to the list of elements to sum
      ops.add(Multiplication.create(termExpression));
    
    }
    return Sum.create(ops).withSign(negative);
  }

  @override
  num evaluate(Map<String, double> p) {
    num value = 1;
    operands.forEach((bscFunction f) {
      value *= f.evaluate(p);
    });
    return value;
  }

  @override
  String toString([bool handleMinus = true]) {
    String s = '';
    if (negative && handleMinus) s += '-';

    s += '(';

    s += operands[0].toString(true);

    for (int i = 1; i < operands.length; ++i) {
      s += '*' + operands[i].toString(true);
    }

    s += ')';

    return s;
  }

  @override
  bscFunction withSign(bool negative) => Multiplication._(operands, negative);
}
