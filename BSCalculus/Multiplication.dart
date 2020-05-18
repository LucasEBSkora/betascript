import 'Division.dart';
import 'Exponentiation.dart';
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
  

    _openOtherMultiplications(operands);

    //if there are any divions in the operands, makes a new division with its numerator with
    //the other operands added, and its denominator
    for (int i = 0; i < operands.length; ++i) {
      List<bscFunction> divisions = List();


      for (int i = 0; i < operands.length;) {
        if (operands[i] is Division) {
          divisions.add(operands.removeAt(i));

        } else ++i;
      }

      if (divisions.length != 0) {
        List<bscFunction> nums = List();
        List<bscFunction> dens = List();

        nums.addAll(operands);

        for (Division f in divisions) {
          bscFunction num = f.numerator;
          if (num is Multiplication)
            nums.addAll(num.operands);
          else 
            nums.add(num);

          bscFunction den = f.denominator;
          if (den is Multiplication)
            dens.addAll(den.operands);
          else 
            dens.add(den);
        }

        return Division.create(nums, dens);

      }

    }




    bool negativeForNumbers = _multiplyNumbers(operands);
    bool negativeOthers = _consolidateNegatives(operands);

    bool negative = (negativeForNumbers && !negativeOthers) || (!negativeForNumbers && negativeOthers);

    _createExponents(operands);
    
        if (operands.length == 0) return Number(0);
        if (operands.length == 1) return operands[0].withSign(negative);
        else return Multiplication._(operands, negative);
      }
    
      ///If there are other Multiplications in the operand list, takes its operands and adds them to the list
      static void _openOtherMultiplications(List<bscFunction> operands) {
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
    
      ///Returns the value of "negative" and takes all numbers be multiplied.
      static bool _multiplyNumbers(List<bscFunction> operands) {
        double number = 1;
        bool negative = false;
    
        //used to store named numbers, because they shouldn't be multiplied with the others
        //the key is the name of the number, the double is its value, and the int is the power
        //to which it should be raised
        Map<String, Pair<double, int>> namedNumbers = Map();
    
        int i = 0;
        while (i < operands.length) {
          //if the operand is a number, removes it and
          if (operands[i] is Number) {
            Number n = operands.removeAt(i);
            //if it's a regular number, just multiplies the accumulator
            if (!n.isNamed)
              number *= n.value;
            else {
              //if it's named, adds it to the map.
    
              if (!namedNumbers.containsKey(n.name))
                namedNumbers[n.name] = Pair<double, int>(n.absvalue, 0);
    
              ++namedNumbers[n.name].second;
            
              if (n.negative) number *= -1;
            }
          } else
            ++i;
        }
    
        //if the number is 0, there was a 0 in the List, so the multiplications is 0.
        if (number == 0) operands.clear();
        else {
          //makes a new list with the normal number and the named numbers
          List<bscFunction> numbers = List<bscFunction>();
          if (number < 0) negative = true;
          if (number.abs() != 1) numbers.add(Number(number.abs()));
    
          //adds the named numbers
          for (String key in namedNumbers.keys) {
            if (namedNumbers[key].second != 0)
              numbers.add(Number.named(namedNumbers[key].first, key) ^ Number(namedNumbers[key].second));
          }
    
          //adds the numbers to the operands
          operands.insertAll(0, numbers);
    
          //if the multiplication was only numbers and the number left is 1, adds 1 to the operands.
          if (number.abs() == 1 && operands.length == 0) operands.add(Number(1));
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

      ///if operands can be joined as an exponentiation, does it
      static void _createExponents(List<bscFunction> operands) {
        
        for (int i = 0; i < operands.length; ++i) {
          
          //for each operand, divides it into base and exponent, event if the exponent is 1
          bscFunction f = operands[i];

          bscFunction base;
          bscFunction exponent;
          
          if (f is Exponentiation) {
            base = f.base;
            exponent = f.exponent;
          } else {
            base = f;
            exponent = Number(1);
          }

          //for every following operand, checks if the other is equal to the base or if it is also an exponentiation with the same base.
          for (int j = i + 1; j < operands.length; ++j) {
            bscFunction g = operands[j];
            if (g is Exponentiation) {
              if (g.base == base) {
                operands.removeAt(j);
                exponent += g.exponent;
              }
            } else {
              if (g == base) {
                operands.removeAt(j);
                exponent += Number(1);
              }
            }

          }
          

          if (exponent != Number(1)) {
            operands.removeAt(i);
            operands.insert(i, base^exponent);
          }

        }
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
