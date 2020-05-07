import 'Sum.dart';
import 'bscFunction.dart';
import 'Variable.dart';

class Multiplication extends bscFunction {
  final List<bscFunction> operands;


  Multiplication._(List<bscFunction> this.operands, [bool negative = false]) : super(negative);

  static bscFunction create(List<bscFunction> operands) {
    bool negative = false;

    
    //TODO: perform simplifications

    return Multiplication._(operands, negative);
  }

  @override
  bscFunction derivative(Variable v) {
    List<bscFunction> ops;

    for (int i = 0; i < operands.length; ++i) {
      List<bscFunction> term = [...operands];
      term.removeAt(i);
      ops.add(Multiplication.create(term.map((f) {
        return f.derivative(v);
      })));

    }
    return Sum.create(ops);
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


    s += '('+  operands[0].toString(true) + ")";

    for (int i = 1; i < operands.length; ++i) {
      s += '*'+ operands[i].toString(true);
    }

     s += ')';

    return s;
  }

  @override
  bscFunction ignoreNegative() => Multiplication._(operands, false);

  @override
  bscFunction opposite() => Multiplication._(operands, !negative);

}