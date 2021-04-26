import '../function.dart';
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

class PartialDerivative implements FunctionVisitor<BSFunction> {
  final Variable v;

  const PartialDerivative(this.v);

  BSFunction _derivative(BSFunction f) => f.accept<BSFunction>(this);

  @override
  BSFunction visitAbs(AbsoluteValue f) =>
      (sgn(f.operand) * _derivative(f.operand));

  @override
  BSFunction visitArCosH(ArCosH f) =>
      (_derivative(f.operand) / root((f.operand ^ n(2)) - n(1)));

  @override
  BSFunction visitArCscH(ArCscH f) => (-_derivative(f.operand) /
      (abs(f.operand) * root((f.operand ^ n(2)) + n(1))));

  @override
  BSFunction visitArCtgH(ArCtgH f) =>
      (_derivative(f.operand) / (n(1) - f.operand ^ n(2)));

  @override
  BSFunction visitArSecH(ArSecH f) =>
      (-_derivative(f.operand) / (f.operand * root(n(1) - (f.operand ^ n(2)))));

  @override
  BSFunction visitCos(Cos f) => -sin(f.operand) * _derivative(f.operand);

  @override
  BSFunction visitCosH(CosH f) => sinh(f.operand) * _derivative(f.operand);

  @override
  BSFunction visitCscH(CscH f) =>
      (-ctgh(f.operand) * csch(f.operand) * _derivative(f.operand));

  @override
  BSFunction visitCtgH(CtgH f) =>
      -(csch(f.operand) ^ n(2)) * _derivative(f.operand);

  @override
  BSFunction visitDivision(Division f) =>
      ((_derivative(f.numerator) * f.denominator) -
          (f.numerator * _derivative(f.denominator))) /
      (f.denominator ^ n(2));

  @override
  BSFunction visitExponentiation(Exponentiation f) =>
      f *
      ((f.exponent * _derivative(log(f.base))) +
          _derivative(f.exponent) * log(f.base));

  //if base is also a function, uses log_b(a) = ln(a)/ln(b) s
  @override
  BSFunction visitLog(Log f) {
    print(f.operand);
    return (f.base is Number)
      ? (_derivative(f.operand) / (log(f.base) * f.operand))
      : _derivative(log(f.operand) / log(f.base));
  }

  @override
  BSFunction visitSecH(SecH f) =>
      -sech(f.operand) * tanh(f.operand) * _derivative(f.operand);

  @override
  BSFunction visitSinH(SinH f) => cosh(f.operand) * _derivative(f.operand);
  @override
  BSFunction visitTanH(TanH f) =>
      (sech(f.operand) ^ n(2)) * _derivative(f.operand);

  @override
  BSFunction visitVariable(Variable f) => n((v.name == f.name) ? 1 : 0);

  @override
  BSFunction visitArSinH(ArSinH f) =>
      (_derivative(f.operand) / root(n(1) + (f.operand ^ n(2))));

  @override
  BSFunction visitArTanH(ArTanH f) =>
      (_derivative(f.operand) / (n(1) - (f.operand ^ n(2))));

  @override
  BSFunction visitArcCos(ArcCos f) =>
      (-_derivative(f.operand) / root(n(1) - (f.operand ^ n(2))));

  @override
  BSFunction visitArcCsc(ArcCsc f) =>
      -_derivative(f.operand) /
      (abs(f.operand) * root((f.operand ^ n(2)) + n(1)));

  @override
  BSFunction visitArcCtg(ArcCtg f) =>
      (-_derivative(f.operand) / (n(1) + (f.operand ^ n(2))));

  @override
  BSFunction visitArcSec(ArcSec f) => (_derivative(f.operand) /
      (abs(f.operand) * root((f.operand ^ n(2)) - n(1))));

  @override
  BSFunction visitArcSin(ArcSin f) =>
      _derivative(f.operand) / root(n(1) - (f.operand ^ n(2)));

  @override
  BSFunction visitArcTan(ArcTan f) =>
      (_derivative(f.operand) / (n(1) + (f.operand ^ n(2))));

  @override
  BSFunction visitCsc(Csc f) =>
      (-csc(f.operand) * ctg(f.operand) * _derivative(f.operand));

  @override
  BSFunction visitCtg(Ctg f) =>
      -(csc(f.operand) ^ n(2)) * _derivative(f.operand);

  @override
  BSFunction visitMultiplication(Multiplication f) {
    final ops = <BSFunction>[];

    for (int i = 0; i < f.operands.length; ++i) {
      //copies list
      final term = f.operands.toList();

      term.insert(i, _derivative(term.removeAt(i)));
      //removes "current" operand (which isn't derived)

      ops.add(multiply(term));
    }

    return add(ops);
  }

  @override
  BSFunction visitNegative(Negative f) => negative(_derivative(f.operand));

  @override
  BSFunction visitNumber(Number f) => n(0);

  @override
  BSFunction visitRoot(Root f) =>
      (n(1 / 2) * (f.operand ^ n(-1 / 2)) * _derivative(f.operand));

  @override
  BSFunction visitSec(Sec f) =>
      (sec(f.operand) * tan(f.operand) * _derivative(f.operand));

  //The derivative of the sign function is either 0 or undefined.
  @override
  BSFunction visitSignum(Signum f) => n(0);

  @override
  BSFunction visitSin(Sin f) => cos(f.operand) * _derivative(f.operand);

  @override
  BSFunction visitSum(Sum f) =>
      add(f.operands.map((BSFunction g) => _derivative(g)).toList());

  @override
  BSFunction visitTan(Tan f) =>
      (sec(f.operand) ^ n(2)) * _derivative(f.operand);

  @override
  BSFunction visitDerivativeOfUnknown(DerivativeOfUnknown f) =>
      DerivativeOfUnknown(f.name, f.variables, [...f.variables, v]);

  @override
  BSFunction visitUnknown(Unknown f) => DerivativeOfUnknown(f.name, f.variables, [v]);
}
