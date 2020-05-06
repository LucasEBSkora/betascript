import 'Sum.dart';
import 'bscFunction.dart';
import 'Variable.dart';

class Multiplication extends bscFunction {
  final List<bscFunction> _operands;


  Multiplication._(List<bscFunction> this._operands, [bool negative = false]) : super(negative);

  static bscFunction create(List<bscFunction> operands) {
    bool negative = false;

    
    //TODO: perform simplifications

    return Multiplication._(operands, negative);
  }

  @override
  bscFunction derivative(Variable v) {
    List<bscFunction> ops;


    for (int i = 0; i < _operands.length; ++i) {
      List<bscFunction> term = [..._operands];
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
    _operands.forEach((bscFunction f) {
      value *= f.evaluate(p);
    });
    return value;
  }

  @override 
  String toString([bool handleMinus = true]) {
    String s = '';
    if (negative && handleMinus) s += '-';

    s += '(';


    s += '('+  _operands[0].toString(true) + ")";

    for (int i = 1; i < _operands.length; ++i) {
      s += '*'+ _operands[i].toString(true);
    }

     s += ')';

    return s;
  }

  @override
  bscFunction ignoreNegative() {
    return Multiplication._(_operands, false);
  }

  @override
  bscFunction opposite() {
    return Multiplication._(_operands, !negative);
  }

}