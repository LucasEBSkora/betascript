import 'Token.dart';
abstract class ExprVisitor {
  dynamic visitBinaryExpr(BinaryExpr e);
  dynamic visitGroupingExpr(GroupingExpr e);
  dynamic visitLiteralExpr(LiteralExpr e);
  dynamic visitUnaryExpr(UnaryExpr e);
  dynamic visitVariableExpr(VariableExpr e);
  dynamic visitAssignExpr(AssignExpr e);

}

abstract class Expr  {
  dynamic accept(ExprVisitor v);

}

class BinaryExpr extends Expr {
  ///operand to the left of the operator
  final Expr left;
  ///operator
  final Token op;
  ///operand to the right of the operator
  final Expr right;
  BinaryExpr(Expr this.left, Token this.op, Expr this.right);
  dynamic accept(ExprVisitor v) => v.visitBinaryExpr(this);

}

class GroupingExpr extends Expr {
  ///A grouping is a collection of other Expressions, so it holds only another expression.
  final Expr expression;
  GroupingExpr(Expr this.expression);
  dynamic accept(ExprVisitor v) => v.visitGroupingExpr(this);

}

class LiteralExpr extends Expr {
  ///Literals are numbers, strings, booleans or null. This field holds one of them.
  final dynamic value;
  LiteralExpr(dynamic this.value);
  dynamic accept(ExprVisitor v) => v.visitLiteralExpr(this);

}

class UnaryExpr extends Expr {
  ///operator
  final Token op;
  ///all Unary operators have the operand to their right.
  final Expr right;
  UnaryExpr(Token this.op, Expr this.right);
  dynamic accept(ExprVisitor v) => v.visitUnaryExpr(this);

}

class VariableExpr extends Expr {
  ///The token containing the variable's name
  final Token name;
  VariableExpr(Token this.name);
  dynamic accept(ExprVisitor v) => v.visitVariableExpr(this);

}

class AssignExpr extends Expr {
  ///The name of the variable being assigned to
  final Token name;
  ///The expression whose result should be assigned to the variable
  final Expr value;
  AssignExpr(Token this.name, Expr this.value);
  dynamic accept(ExprVisitor v) => v.visitAssignExpr(this);

}

