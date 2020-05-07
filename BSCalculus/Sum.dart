import 'Variable.dart';
import 'bscFunction.dart';

class Sum extends bscFunction {
  final List<bscFunction> operands;


  Sum._(List<bscFunction> this.operands, [bool negative = false]) : super(negative);

  static bscFunction create(List<bscFunction> operands) {
    bool negative = false;

    //TODO: perform simplifications

    return Sum._(operands, negative);
  }

  @override
  bscFunction derivative(Variable v) {

    return Sum.create(
      operands.map((bscFunction f) {
        return f.derivative(v);
      })
    );
  }

  @override
  num evaluate(Map<String, double> p) {
    num value = 0;
    operands.forEach((bscFunction f) {
      value += f.evaluate(p);
    });
    return value;
  }

  @override
  bscFunction ignoreNegative() => Sum._(operands, false);

  @override
  bscFunction opposite() => Sum._(operands, !negative);

  @override 
  String toString([bool handleMinus = true]) {
    String s = '';
    if (negative && handleMinus) s += '-';

    if (negative) s += '(';

    s += operands[0].toString(true) + " ";

    for (int i = 1; i < operands.length; ++i) {
      s += 
        ((operands[i].negative) ? "- " : "+ ") +
        operands[i].toString(false);
    }

    if (negative) s += ')';

    return s;
  }

}