import 'Expr.dart';

//prints ASTs - Abstract Sintax Trees
class ASTPrinter extends ExprVisitor {
  String print(Expr expr) => expr.accept(this);

  @override
  String visitBinaryExpr(BinaryExpr e) => _parenthesize(e.op.lexeme, [e.left, e.right]);

  @override
  String visitGroupingExpr(GroupingExpr e) => _parenthesize("group", [e.expression]);

  @override
  String visitLiteralExpr(LiteralExpr e) => (e.value == null) ? 'nil' : e.value.toString();

  @override
  String visitUnaryExpr(UnaryExpr e) => _parenthesize(e.op.lexeme, [e.right]);


  @override
  visitVariableExpr(Expr e) => (e as VariableExpr).name.lexeme;

  @override
  visitAssignExpr(AssignExpr e) => _parenthesize('(= ' + e.name.lexeme, [e.value]);

  String _parenthesize(String lexeme, List<Expr> expressions) {
    String result = '(' + lexeme;

    for (Expr s in expressions) {
      result += ' ' + s.accept(this);
    } 
    
    result += ')';

    return result;
  }
}