import 'Expr.dart';

//prints ASTs - Abstract Sintax Trees
class ASTPrinter extends ExprVisitor {
  String print(Expr expr) => expr.accept(this);

  @override
  String visitBinaryExpr(Expr e) {
    BinaryExpr b = e;
    return _parenthesize(b.op.lexeme, [b.left, b.right]);
  }

  @override
  String visitGroupingExpr(Expr e) {
    GroupingExpr g = e;
    return _parenthesize("group", [g.expression]);
  }

  @override
  String visitLiteralExpr(Expr e) {
    LiteralExpr g = e;
    if (g.value == null) return 'nil';
    return g.value.toString();
  }

  @override
  String visitUnaryExpr(Expr e) {
    UnaryExpr u = e;
    return _parenthesize(u.op.lexeme, [u.right]);
  }

  String _parenthesize(String lexeme, List<Expr> expressions) {
    String result = '(' + lexeme;

    for (Expr s in expressions) {
      result += ' ' + s.accept(this);
    } 
    
    result += ')';

    return result;
  }
}
