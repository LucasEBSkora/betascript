import 'Expr.dart';
abstract class StmtVisitor {
  dynamic visitExpressionStmt(Stmt s);
  dynamic visitPrintStmt(Stmt s);

}

abstract class Stmt  {
  dynamic accept(StmtVisitor v);

}

class ExpressionStmt extends Stmt {
  ///Expression statements are basically wrappers for Expressions
  final Expr expression;
  ExpressionStmt(Expr this.expression);
  dynamic accept(StmtVisitor v) => v.visitExpressionStmt(this);

}

class PrintStmt extends Stmt {
  ///print statements evaluate and then print their expressions
  final Expr expression;
  PrintStmt(Expr this.expression);
  dynamic accept(StmtVisitor v) => v.visitPrintStmt(this);

}

