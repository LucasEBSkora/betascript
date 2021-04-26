import 'token.dart';

abstract class ExprVisitor<T> {
  T visitAssignExpr(AssignExpr e);
  T visitBinaryExpr(BinaryExpr e);
  T visitCallExpr(CallExpr e);
  T visitGetExpr(GetExpr e);
  T visitGroupingExpr(GroupingExpr e);
  T visitLiteralExpr(LiteralExpr e);
  T visitUnaryExpr(UnaryExpr e);
  T visitVariableExpr(VariableExpr e);
  T visitLogicBinaryExpr(LogicBinaryExpr e);
  T visitSetExpr(SetExpr e);
  T visitThisExpr(ThisExpr e);
  T visitSuperExpr(SuperExpr e);
  T visitDerivativeExpr(DerivativeExpr e);
  T visitIntervalDefinitionExpr(IntervalDefinitionExpr e);
  T visitRosterDefinitionExpr(RosterDefinitionExpr e);
  T visitBuilderDefinitionExpr(BuilderDefinitionExpr e);
  T visitSetBinaryExpr(SetBinaryExpr e);
  T visitExplainExpr(ExplainExpr e);
}

abstract class Expr {
  const Expr();
  T accept<T>(ExprVisitor v);
}

class AssignExpr extends Expr {
  ///The name of the variable being assigned to
  final Token name;

  ///The expression whose result should be assigned to the variable
  final Expr value;

  const AssignExpr(this.name, this.value);
  T accept<T>(ExprVisitor v) => v.visitAssignExpr(this);
}

class BinaryExpr extends Expr {
  ///operand to the left of the operator
  final Expr left;

  ///operator
  final Token op;

  ///operand to the right of the operator
  final Expr right;

  const BinaryExpr(this.left, this.op, this.right);
  T accept<T>(ExprVisitor v) => v.visitBinaryExpr(this);
}

class CallExpr extends Expr {
  ///The routine/function/method being called
  final Expr callee;

  ///The parentheses token
  final Token paren;

  ///The list of arguments being passed
  final List<Expr> arguments;

  const CallExpr(this.callee, this.paren, this.arguments);
  T accept<T>(ExprVisitor v) => v.visitCallExpr(this);
}

class GetExpr extends Expr {
  ///The object whose field is being accessed
  final Expr object;

  ///The field being accessed
  final Token name;

  const GetExpr(this.object, this.name);
  T accept<T>(ExprVisitor v) => v.visitGetExpr(this);
}

class GroupingExpr extends Expr {
  ///A grouping is a collection of other Expressions, so it holds only another expression.
  final Expr expression;

  const GroupingExpr(this.expression);
  T accept<T>(ExprVisitor v) => v.visitGroupingExpr(this);
}

class LiteralExpr extends Expr {
  ///Literals are numbers, strings, booleans or null. This field holds one of them.
  final  value;

  const LiteralExpr(this.value);
  T accept<T>(ExprVisitor v) => v.visitLiteralExpr(this);
}

class UnaryExpr extends Expr {
  ///operator (this type is used for unary operators both to the left and to the right)
  final Token op;

  ///The operand on which the operator is applied
  final Expr operand;

  const UnaryExpr(this.op, this.operand);
  T accept<T>(ExprVisitor v) => v.visitUnaryExpr(this);
}

class VariableExpr extends Expr {
  ///The token containing the variable's name
  final Token name;

  const VariableExpr(this.name);
  T accept<T>(ExprVisitor v) => v.visitVariableExpr(this);
}

class LogicBinaryExpr extends Expr {
  ///operand to the left of the operator
  final Expr left;

  ///operator
  final Token op;

  ///operand to the right of the operator
  final Expr right;

  const LogicBinaryExpr(this.left, this.op, this.right);
  T accept<T>(ExprVisitor v) => v.visitLogicBinaryExpr(this);
}

class SetExpr extends Expr {
  ///Object whose field is being set
  final Expr object;

  ///name of the field being set
  final Token name;

  ///The value being assigned to the field
  final Expr value;

  const SetExpr(this.object, this.name, this.value);
  T accept<T>(ExprVisitor v) => v.visitSetExpr(this);
}

class ThisExpr extends Expr {
  ///The token containing the keyword 'this'
  final Token keyword;

  const ThisExpr(this.keyword);
  T accept<T>(ExprVisitor v) => v.visitThisExpr(this);
}

class SuperExpr extends Expr {
  ///The token containing the keyword 'super'
  final Token keyword;

  ///The method being accessed
  final Token method;

  const SuperExpr(this.keyword, this.method);
  T accept<T>(ExprVisitor v) => v.visitSuperExpr(this);
}

class DerivativeExpr extends Expr {
  ///The token containing the first 'del' keyword
  final Token keyword;

  ///The function whose derivative is being calculated
  final Expr derivand;

  ///Variables this function is being derivated in
  final List<Expr> variables;

  const DerivativeExpr(this.keyword, this.derivand, this.variables);
  T accept<T>(ExprVisitor v) => v.visitDerivativeExpr(this);
}

class IntervalDefinitionExpr extends Expr {
  ///token containing '[' or '(' 
  final Token left;

  ///left bound
  final Expr a;

  ///right bound
  final Expr b;

  ///token containing ']' or ')' 
  final Token right;

  const IntervalDefinitionExpr(this.left, this.a, this.b, this.right);
  T accept<T>(ExprVisitor v) => v.visitIntervalDefinitionExpr(this);
}

class RosterDefinitionExpr extends Expr {
  ///token containing '{' 
  final Token left;

  ///elements of the set
  final List<Expr> elements;

  ///token containing '}' 
  final Token right;

  const RosterDefinitionExpr(this.left, this.elements, this.right);
  T accept<T>(ExprVisitor v) => v.visitRosterDefinitionExpr(this);
}

class BuilderDefinitionExpr extends Expr {
  ///token containing '{' 
  final Token left;

  ///parameters used in the rule
  final List<Token> parameters;

  ///rule used to test for membership
  final Expr rule;

  ///token containing '|' 
  final Token bar;

  ///token containing '}' 
  final Token right;

  const BuilderDefinitionExpr(this.left, this.parameters, this.rule, this.bar, this.right);
  T accept<T>(ExprVisitor v) => v.visitBuilderDefinitionExpr(this);
}

class SetBinaryExpr extends Expr {
  ///left operand
  final Expr left;

  ///token containing operator
  final Token operator;

  ///right operand
  final Expr right;

  const SetBinaryExpr(this.left, this.operator, this.right);
  T accept<T>(ExprVisitor v) => v.visitSetBinaryExpr(this);
}

class ExplainExpr extends Expr {
  ///'explain' keyword
  final Token keyword;

  ///what should be understood
  final Expr operand;

  const ExplainExpr(this.keyword, this.operand);
  T accept<T>(ExprVisitor v) => v.visitExplainExpr(this);
}

