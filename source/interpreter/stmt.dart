import 'expr.dart';
import 'token.dart';

abstract class StmtVisitor<T> {
  T visitExpressionStmt(ExpressionStmt s);
  T visitPrintStmt(PrintStmt s);
  T visitVarStmt(VarStmt s);
  T visitBlockStmt(BlockStmt s);
  T visitIfStmt(IfStmt s);
  T visitRoutineStmt(RoutineStmt s);
  T visitWhileStmt(WhileStmt s);
  T visitReturnStmt(ReturnStmt s);
  T visitClassStmt(ClassStmt s);
  T visitDirectiveStmt(DirectiveStmt s);
}

abstract class Stmt {
  const Stmt();
  T accept<T>(StmtVisitor v);
}

class ExpressionStmt extends Stmt {
  ///Expression statements are basically wrappers for Expressions
  final Expr expression;

  const ExpressionStmt(this.expression);
  T accept<T>(StmtVisitor v) => v.visitExpressionStmt(this);
}

class PrintStmt extends Stmt {
  ///print statements evaluate and then print their expressions
  final Expr expression;

  const PrintStmt(this.expression);
  T accept<T>(StmtVisitor v) => v.visitPrintStmt(this);
}

class VarStmt extends Stmt {
  ///The token holding the variable's name
  final Token name;

  ///for functions, the list of variables it is defined in
  final List<Token> parameters;

  ///If the variable is initialized on declaration, the inicializer is stored here
  final Expr? initializer;

  const VarStmt(this.name, this.parameters, this.initializer);
  T accept<T>(StmtVisitor v) => v.visitVarStmt(this);
}

class BlockStmt extends Stmt {
  ///A block contains a sequence of Statements, being basically a region of code with specific scope
  final List<Stmt> statements;

  const BlockStmt(this.statements);
  T accept<T>(StmtVisitor v) => v.visitBlockStmt(this);
}

class IfStmt extends Stmt {
  ///If this condition evaluates to True, execute ThenBranch. If it doesn't, execute elseBranch
  final Expr condition;

  ///
  final Stmt thenBranch;

  ///
  final Stmt? elseBranch;

  const IfStmt(this.condition, this.thenBranch, this.elseBranch);
  T accept<T>(StmtVisitor v) => v.visitIfStmt(this);
}

class RoutineStmt extends Stmt {
  ///The routine's name
  final Token name;

  ///The parameters the routine takes
  final List<Token> parameters;

  ///The routine body
  final List<Stmt> body;

  const RoutineStmt(this.name, this.parameters, this.body);
  T accept<T>(StmtVisitor v) => v.visitRoutineStmt(this);
}

class WhileStmt extends Stmt {
  ///The token containing the while or for keyword
  final Token token;

  ///while this condition evaluates to True, execute body.
  final Expr condition;

  ///
  final Stmt body;

  const WhileStmt(this.token, this.condition, this.body);
  T accept<T>(StmtVisitor v) => v.visitWhileStmt(this);
}

class ReturnStmt extends Stmt {
  ///The token containing the keyword 'return'
  final Token keyword;

  ///The expression whose value should be returned
  final Expr value;

  const ReturnStmt(this.keyword, this.value);
  T accept<T>(StmtVisitor v) => v.visitReturnStmt(this);
}

class ClassStmt extends Stmt {
  ///Token containing the class' name
  final Token name;

  ///A variable containing a reference to the superclass
  final VariableExpr? superclass;

  ///A list of the class' methods
  final List<RoutineStmt> methods;

  const ClassStmt(this.name, this.superclass, this.methods);
  T accept<T>(StmtVisitor v) => v.visitClassStmt(this);
}

class DirectiveStmt extends Stmt {
  ///Token containing the directive
  final Token token;

  ///the directive being issued
  final String directive;

  const DirectiveStmt(this.token, this.directive);
  T accept<T>(StmtVisitor v) => v.visitDirectiveStmt(this);
}

