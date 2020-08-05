import 'Token.dart';
abstract class ExprVisitor {
  dynamic visitAssignExpr(AssignExpr e);
  dynamic visitBinaryExpr(BinaryExpr e);
  dynamic visitCallExpr(CallExpr e);
  dynamic visitGetExpr(GetExpr e);
  dynamic visitGroupingExpr(GroupingExpr e);
  dynamic visitLiteralExpr(LiteralExpr e);
  dynamic visitUnaryExpr(UnaryExpr e);
  dynamic visitVariableExpr(VariableExpr e);
  dynamic visitlogicBinaryExpr(logicBinaryExpr e);
  dynamic visitSetExpr(SetExpr e);
  dynamic visitThisExpr(ThisExpr e);
  dynamic visitSuperExpr(SuperExpr e);
  dynamic visitDerivativeExpr(DerivativeExpr e);

}

abstract class Expr {
 dynamic accept(ExprVisitor v);
}

class AssignExpr extends Expr {
  ///The name of the variable being assigned to
  final Token name;
  ///The expression whose result should be assigned to the variable
  final Expr value;
  AssignExpr(Token this.name, Expr this.value);
 dynamic accept(ExprVisitor v) => v.visitAssignExpr(this);

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

class CallExpr extends Expr {
  ///The routine/function/method being called
  final Expr callee;
  ///The parentheses token
  final Token paren;
  ///The list of arguments being passed
  final List<Expr> arguments;
  CallExpr(Expr this.callee, Token this.paren, List<Expr> this.arguments);
 dynamic accept(ExprVisitor v) => v.visitCallExpr(this);

}

class GetExpr extends Expr {
  ///The object whose field is being accessed
  final Expr object;
  ///The field being accessed
  final Token name;
  GetExpr(Expr this.object, Token this.name);
 dynamic accept(ExprVisitor v) => v.visitGetExpr(this);

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
  ///operator (this type is used for unary operators both to the left and to the right)
  final Token op;
  ///The operand on which the operator is applied
  final Expr operand;
  UnaryExpr(Token this.op, Expr this.operand);
 dynamic accept(ExprVisitor v) => v.visitUnaryExpr(this);

}

class VariableExpr extends Expr {
  ///The token containing the variable's name
  final Token name;
  VariableExpr(Token this.name);
 dynamic accept(ExprVisitor v) => v.visitVariableExpr(this);

}

class logicBinaryExpr extends Expr {
  ///operand to the left of the operator
  final Expr left;
  ///operator
  final Token op;
  ///operand to the right of the operator
  final Expr right;
  logicBinaryExpr(Expr this.left, Token this.op, Expr this.right);
 dynamic accept(ExprVisitor v) => v.visitlogicBinaryExpr(this);

}

class SetExpr extends Expr {
  ///Object whose field is being set
  final Expr object;
  ///name of the field being set
  final Token name;
  ///The value being assigned to the field
  final Expr value;
  SetExpr(Expr this.object, Token this.name, Expr this.value);
 dynamic accept(ExprVisitor v) => v.visitSetExpr(this);

}

class ThisExpr extends Expr {
  ///The token containing the keyword 'this'
  final Token keyword;
  ThisExpr(Token this.keyword);
 dynamic accept(ExprVisitor v) => v.visitThisExpr(this);

}

class SuperExpr extends Expr {
  ///The token containing the keyword 'super'
  final Token keyword;
  ///The method being accessed
  final Token method;
  SuperExpr(Token this.keyword, Token this.method);
 dynamic accept(ExprVisitor v) => v.visitSuperExpr(this);

}

class DerivativeExpr extends Expr {
  ///The token containing the first 'del' keyword
  final Token keyword;
  ///The function whose derivative is being calculated
  final Expr derivand;
  ///Variables this function is being derivated in
  final List<Expr> variables;
  DerivativeExpr(Token this.keyword, Expr this.derivand, List<Expr> this.variables);
 dynamic accept(ExprVisitor v) => v.visitDerivativeExpr(this);

}

