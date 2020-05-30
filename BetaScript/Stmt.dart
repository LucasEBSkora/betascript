import 'Expr.dart';import 'Token.dart';
abstract class StmtVisitor {
  dynamic visitExpressionStmt(Stmt s);
  dynamic visitPrintStmt(Stmt s);
  dynamic visitVarStmt(Stmt s);

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

class VarStmt extends Stmt {
  ///The token holding the variable's name
  final Token name;
  ///If the variable is initialized on declaration, the inicializer is stored here
  final Expr initializer;
  VarStmt(Token this.name, Expr this.initializer);
  dynamic accept(StmtVisitor v) => v.visitVarStmt(this);

}

