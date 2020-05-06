import 'Variable.dart';
import 'bscFunction.dart';

class Sum extends bscFunction {
  final List<bscFunction> _operands;


  Sum._(List<bscFunction> this._operands, [bool negative = false]) : super(negative);

  static bscFunction create(List<bscFunction> operands) {
    bool negative = false;

    //TODO: perform simplifications

    return Sum._(operands, negative);
  }

  @override
  bscFunction derivative(Variable v) {

    return Sum.create(
      _operands.map((bscFunction f) {
        return f.derivative(v);
      })
    );
  }

  @override
  num evaluate(Map<String, double> p) {
    num value = 0;
    _operands.forEach((bscFunction f) {
      value += f.evaluate(p);
    });
    return value;
  }

  @override 
  String toString([bool handleMinus = true]) {
    String s = '';
    if (negative && handleMinus) s += '-';

    if (negative) s += '(';

    s += _operands[0].toString(true) + " ";

    for (int i = 1; i < _operands.length; ++i) {
      s += 
        ((_operands[i].negative) ? "- " : "+ ") +
        _operands[i].toString(false);
    }

    if (negative) s += ')';

    return s;
  }

  @override
  bscFunction ignoreNegative() {
    return Sum._(_operands, false);
  }

  @override
  bscFunction opposite() {
    return Sum._(_operands, !negative);
  }

}