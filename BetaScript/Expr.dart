import 'Token.dart';

abstract class ExprVisitor {
  dynamic visitBinaryExpr(Expr e);
  dynamic visitGroupingExpr(Expr e);
  dynamic visitLiteralExpr(Expr e);
  dynamic visitUnaryExpr(Expr e);

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
  ///Literals are numbers, strings, bools or null. This field holds one of them.
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

