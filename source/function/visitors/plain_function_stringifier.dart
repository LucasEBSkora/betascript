import '../unknown.dart';
import '../variable.dart';
import '../trig/tan.dart';
import '../trig/sin.dart';
import '../trig/sec.dart';
import '../trig/ctg.dart';
import '../trig/csc.dart';
import '../trig/cos.dart';
import '../sum.dart';
import '../sgn.dart';
import '../root.dart';
import '../number.dart';
import '../negative.dart';
import '../multiplication.dart';
import '../log.dart';
import '../inverse_trig/arctan.dart';
import '../inverse_trig/arcsin.dart';
import '../inverse_trig/arcsec.dart';
import '../inverse_trig/arcctg.dart';
import '../inverse_trig/arccsc.dart';
import '../inverse_trig/arccos.dart';
import '../inverse_hyperbolic/artanh.dart';
import '../inverse_hyperbolic/arsinh.dart';
import '../inverse_hyperbolic/arsech.dart';
import '../inverse_hyperbolic/arctgh.dart';
import '../inverse_hyperbolic/arcsch.dart';
import '../inverse_hyperbolic/arcosh.dart';
import '../hyperbolic/tanh.dart';
import '../hyperbolic/sinh.dart';
import '../hyperbolic/sech.dart';
import '../hyperbolic/ctgh.dart';
import '../hyperbolic/csch.dart';
import '../hyperbolic/cosh.dart';
import '../exponentiation.dart';
import '../division.dart';
import '../abs.dart';
import 'function_visitor.dart';

class PlainFunctionStringifier implements FunctionVisitor<String> {
  @override
  String visitAbs(AbsoluteValue f) => "|${f.operand}|";

  @override
  String visitArCosH(ArCosH f) => "arcosh(${f.operand})";

  @override
  String visitArCscH(ArCscH f) => "arcsch(${f.operand})";

  @override
  String visitArCtgH(ArCtgH f) => "arctgh(${f.operand})";

  @override
  String visitArSecH(ArSecH f) => "arsech(${f.operand})";

  @override
  String visitArSinH(ArSinH f) => "arsinh(${f.operand})";

  @override
  String visitArTanH(ArTanH f) => "artanh(${f.operand})";

  @override
  String visitArcCos(ArcCos f) => "arccos(${f.operand})";

  @override
  String visitArcCsc(ArcCsc f) => "arcsc(${f.operand})";

  @override
  String visitArcCtg(ArcCtg f) => "arcctg(${f.operand})";

  @override
  String visitArcSec(ArcSec f) => "arcsec(${f.operand})";

  @override
  String visitArcSin(ArcSin f) => "arcsin(${f.operand})";

  @override
  String visitArcTan(ArcTan f) => "arctan(${f.operand})";

  @override
  String visitCos(Cos f) => "cos(${f.operand})";

  @override
  String visitCosH(CosH f) => "cosh(${f.operand})";

  @override
  String visitCsc(Csc f) => "csc(${f.operand})";

  @override
  String visitCscH(CscH f) => "csch(${f.operand})";

  @override
  String visitCtg(Ctg f) => "ctg(${f.operand})";

  @override
  String visitCtgH(CtgH f) => "ctgh(${f.operand})";

  @override
  String visitDivision(Division f) => "((${f.numerator})/(${f.denominator}))";

  @override
  String visitExponentiation(Exponentiation f) =>
      "((${f.base})^(${f.exponent}))";

  @override
  String visitLog(Log f) => (f.base == Constants.e)
      ? "ln(${f.operand})"
      : "log(${f.base})(${f.operand})";

  @override
  String visitMultiplication(Multiplication f) {
    var s = '(';

    s += f.operands[0].toString();

    for (var i = 1; i < f.operands.length; ++i) {
      s += '*' + f.operands[i].toString();
    }

    s += ')';

    return s;
  }

  @override
  String visitNegative(Negative f) => "-${f.operand}";

  @override
  String visitNumber(Number f) => f.name;

  @override
  String visitRoot(Root f) => "sqrt(${f.operand})";

  @override
  String visitSec(Sec f) => "sec(${f.operand})";

  @override
  String visitSecH(SecH f) => "sech(${f.operand})";

  @override
  String visitSignum(Signum f) => "sign(${f.operand})";

  @override
  String visitSin(Sin f) => "sin(${f.operand})";

  @override
  String visitSinH(SinH f) => "sinh(${f.operand})";

  @override
  String visitSum(Sum f) {
    var s = '(';

    s += f.operands[0].toString();

    for (int i = 1; i < f.operands.length; ++i) {
      var _op = f.operands[i];
      if (_op is Negative) {
        s += " - ";
        _op = _op.operand;
      } else
        s += " + ";

      s += _op.toString();
    }

    s += ')';

    return s;
  }

  @override
  String visitTan(Tan f) => "tan(${f.operand})";

  @override
  String visitTanH(TanH f) => "tanh(${f.operand})";

  @override
  String visitVariable(Variable f) => f.name;

  @override
  String visitDerivativeOfUnknown(DerivativeOfUnknown f) {
    var derivand = (f.order > 1) ? "∂${f.order}(${f.name})" : "∂(${f.name})";

    List<String> parameters = [];
    for (var i = 0; i < f.derivationVariables.length; ++i) {
      var name = f.derivationVariables[i].name;
      int order = 1;
      while (i < f.derivationVariables.length - 1 && f.derivationVariables[i + 1].name == name) {
        ++i;
        ++order;
      }
      parameters.add("∂" + (order > 1 ? "$order" : "") + name);
    }
    if (parameters.length == 1) return derivand + ' / ' + parameters.single;
    var result = derivand + '/(';
    result += parameters.first;
    for (var param in parameters.sublist(1)) result += "*" + param;
    result += ')';
    return result;
  }

  @override
  String visitUnknown(Unknown f) => f.name;
}
