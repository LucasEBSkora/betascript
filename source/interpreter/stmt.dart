import 'expr.dart';
import 'token.dart';

abstract class StmtVisitor {
  Object visitExpressionStmt(ExpressionStmt s);
  Object visitPrintStmt(PrintStmt s);
  Object visitVarStmt(VarStmt s);
  Object visitBlockStmt(BlockStmt s);
  Object visitIfStmt(IfStmt s);
  Object visitRoutineStmt(RoutineStmt s);
  Object visitWhileStmt(WhileStmt s);
  Object visitReturnStmt(ReturnStmt s);
  Object visitClassStmt(ClassStmt s);
  Object visitDirectiveStmt(DirectiveStmt s);
}

abstract class Stmt {
  const Stmt();
  Object accept(StmtVisitor v);
}

class ExpressionStmt extends Stmt {
  ///Expression statements are basically wrappers for Expressions
  final Expr expression;

  const ExpressionStmt(this.expression);
  Object accept(StmtVisitor v) => v.visitExpressionStmt(this);
}

class PrintStmt extends Stmt {
  ///print statements evaluate and then print their expressions
  final Expr expression;

  const PrintStmt(this.expression);
  Object accept(StmtVisitor v) => v.visitPrintStmt(this);
}

class VarStmt extends Stmt {
  ///The token holding the variable's name
  final Token name;

  ///for functions, the list of variables it is defined in
  final List<Token> parameters;

  ///If the variable is initialized on declaration, the inicializer is stored here
  final Expr initializer;

  const VarStmt(this.name, this.parameters, this.initializer);
  Object accept(StmtVisitor v) => v.visitVarStmt(this);
}

class BlockStmt extends Stmt {
  ///A block contains a sequence of Statements, being basically a region of code with specific scope
  final List<Stmt> statements;

  const BlockStmt(this.statements);
  Object accept(StmtVisitor v) => v.visitBlockStmt(this);
}

class IfStmt extends Stmt {
  ///If this condition evaluates to True, execute ThenBranch. If it doesn't, execute elseBranch
  final Expr condition;

  ///
  final Stmt thenBranch;

  ///
  final Stmt elseBranch;

  const IfStmt(this.condition, this.thenBranch, this.elseBranch);
  Object accept(StmtVisitor v) => v.visitIfStmt(this);
}

class RoutineStmt extends Stmt {
  ///The routine's name
  final Token name;

  ///The parameters the routine takes
  final List<Token> parameters;

  ///The routine body
  final List<Stmt> body;

  const RoutineStmt(this.name, this.parameters, this.body);
  Object accept(StmtVisitor v) => v.visitRoutineStmt(this);
}

class WhileStmt extends Stmt {
  ///The token containing the while or for keyword
  final Token token;

  ///while this condition evaluates to True, execute body.
  final Expr condition;

  ///
  final Stmt body;

  const WhileStmt(this.token, this.condition, this.body);
  Object accept(StmtVisitor v) => v.visitWhileStmt(this);
}

class ReturnStmt extends Stmt {
  ///The token containing the keyword 'return'
  final Token keyword;

  ///The expression whose value should be returned
  final Expr value;

  const ReturnStmt(this.keyword, this.value);
  Object accept(StmtVisitor v) => v.visitReturnStmt(this);
}

class ClassStmt extends Stmt {
  ///Token containing the class' name
  final Token name;

  ///A variable containing a reference to the superclass
  final VariableExpr superclass;

  ///A list of the class' methods
  final List<RoutineStmt> methods;

  const ClassStmt(this.name, this.superclass, this.methods);
  Object accept(StmtVisitor v) => v.visitClassStmt(this);
}

class DirectiveStmt extends Stmt {
  ///Token containing the directive
  final Token token;

  ///the directive being issued
  final String directive;

  const DirectiveStmt(this.token, this.directive);
  Object accept(StmtVisitor v) => v.visitDirectiveStmt(this);
}
