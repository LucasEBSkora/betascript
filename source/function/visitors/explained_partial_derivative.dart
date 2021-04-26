import 'dart:collection';

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
import 'partial_derivative.dart';

class ExplainedPartialDerivative extends FunctionVisitor<String> {
  final PartialDerivative derivator;

  final Variable v;
  final BSFunction _x;
  final BSFunction _y;

  ExplainedPartialDerivative(this.v)
      : derivator = PartialDerivative(v),
        _x = Unknown('u', SplayTreeSet.from(<Variable>{v})),
        _y = Unknown('v', SplayTreeSet.from(<Variable>{v}));

  BSFunction _derivative(BSFunction f) => f.accept(derivator);

  String _explain(BSFunction generic, BSFunction f) =>
      "d($generic)/d$v is ${_derivative(generic)}, so ∂($f)/∂$v = ${_derivative(f)}\n";

  @override
  String visitAbs(AbsoluteValue f) =>
      _explain(abs(_x), f) + f.operand.accept(this);

  @override
  String visitArCosH(ArCosH f) =>
      _explain(arcosh(_x), f) + f.operand.accept(this);

  @override
  String visitArCscH(ArCscH f) =>
      _explain(arcsch(_x), f) + f.operand.accept(this);

  @override
  String visitArCtgH(ArCtgH f) =>
      _explain(arctgh(_x), f) + f.operand.accept(this);

  @override
  String visitArSecH(ArSecH f) =>
      _explain(arsech(_x), f) + f.operand.accept(this);

  @override
  String visitCos(Cos f) => _explain(cos(_x), f) + f.operand.accept(this);

  @override
  String visitCosH(CosH f) => _explain(cosh(_x), f) + f.operand.accept(this);

  @override
  String visitCscH(CscH f) => _explain(csch(_x), f) + f.operand.accept(this);

  @override
  String visitCtgH(CtgH f) => _explain(ctgh(_x), f) + f.operand.accept(this);

  @override
  String visitDivision(Division f) =>
      _explain(_x / _y, f) +
      f.numerator.accept(this) +
      f.denominator.accept(this);

  @override
  String visitExponentiation(Exponentiation f) =>
      _explain(_x ^ _y, f) + f.base.accept(this) + f.exponent.accept(this);

  @override
  String visitLog(Log f) {
    print(log(_x, f.base).accept(derivator));
    if (f.base is Number)
      return _explain(log(_x, f.base), f) + f.operand.accept(this);
    else
      return _explain(log(_x, _y), f) +
          f.operand.accept(this) +
          f.base.accept(this);
  }

  @override
  String visitSecH(SecH f) => _explain(sech(_x), f) + f.operand.accept(this);

  @override
  String visitSinH(SinH f) => _explain(sinh(_x), f) + f.operand.accept(this);

  @override
  String visitTanH(TanH f) => _explain(tanh(_x), f) + f.operand.accept(this);

  @override
  String visitVariable(Variable f) => "";

  @override
  String visitArSinH(ArSinH f) =>
      _explain(arsinh(_x), f) + f.operand.accept(this);

  @override
  String visitArTanH(ArTanH f) =>
      _explain(artanh(_x), f) + f.operand.accept(this);

  @override
  String visitArcCos(ArcCos f) =>
      _explain(arccos(_x), f) + f.operand.accept(this);

  @override
  String visitArcCsc(ArcCsc f) =>
      _explain(arccsc(_x), f) + f.operand.accept(this);

  @override
  String visitArcCtg(ArcCtg f) =>
      _explain(arcctg(_x), f) + f.operand.accept(this);

  @override
  String visitArcSec(ArcSec f) =>
      _explain(arcsec(_x), f) + f.operand.accept(this);

  @override
  String visitArcSin(ArcSin f) =>
      _explain(arcsin(_x), f) + f.operand.accept(this);

  @override
  String visitArcTan(ArcTan f) =>
      _explain(arctan(_x), f) + f.operand.accept(this);

  @override
  String visitCsc(Csc f) => _explain(csc(_x), f) + f.operand.accept(this);

  @override
  String visitCtg(Ctg f) => _explain(ctg(_x), f) + f.operand.accept(this);

  @override
  String visitMultiplication(Multiplication f) {
    final mulEx = multiply(<BSFunction>[
      for (var i = 0; i < f.operands.length; ++i) Unknown("y$i", SplayTreeSet.from(<Variable>{v}))
    ]);
    String explanation =
        "d(u*v)/d$v is (d(u)/d$v) * v + u * d(v)/d$v and " + _explain(mulEx, f);
    for (var op in f.operands) explanation += op.accept(this);
    return explanation;
  }

  @override
  String visitNegative(Negative f) => _explain(-_x, f) + f.operand.accept(this);

  @override
  String visitNumber(Number f) => "";

  @override
  String visitRoot(Root f) => _explain(root(_x), f) + f.operand.accept(this);

  @override
  String visitSec(Sec f) => _explain(sec(_x), f) + f.operand.accept(this);

  @override
  String visitSignum(Signum f) =>
      "The derivative of sign is undefined at 0 and 0 at any other value\n";

  @override
  String visitSin(Sin f) => _explain(sin(_x), f) + f.operand.accept(this);

  @override
  String visitSum(Sum f) {
    String explanation =
        "The derivative of the sum is the sum of the derivatives, so ∂$f/∂$v = ${_derivative(f)}\n";
    for (var op in f.operands) explanation += op.accept(this);
    return explanation;
  }

  @override
  String visitTan(Tan f) => _explain(tan(_x), f) + f.operand.accept(this);

  @override
  String visitDerivativeOfUnknown(DerivativeOfUnknown f) => "";
  @override
  String visitUnknown(Unknown f) => "";
}
