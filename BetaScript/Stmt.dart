import 'Expr.dart';import 'Token.dart';
abstract class StmtVisitor {
  dynamic visitExpressionStmt(ExpressionStmt s);
  dynamic visitPrintStmt(PrintStmt s);
  dynamic visitVarStmt(VarStmt s);
  dynamic visitBlockStmt(BlockStmt s);
  dynamic visitIfStmt(IfStmt s);
  dynamic visitFunctionStmt(FunctionStmt s);
  dynamic visitWhileStmt(WhileStmt s);

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

class BlockStmt extends Stmt {
  ///A block contains a sequence of Statements, being basically a region of code with specific scope
  final List<Stmt> statements;
  BlockStmt(List<Stmt> this.statements);
  dynamic accept(StmtVisitor v) => v.visitBlockStmt(this);

}

class IfStmt extends Stmt {
  ///If this condition evaluates to True, execute ThenBranch. If it doesn't, execute elseBranch
  final Expr condition;
  ///
  final Stmt thenBranch;
  ///
  final Stmt elseBranch;
  IfStmt(Expr this.condition, Stmt this.thenBranch, Stmt this.elseBranch);
  dynamic accept(StmtVisitor v) => v.visitIfStmt(this);

}

class FunctionStmt extends Stmt {
  ///The function's name
  final Token name;
  ///The parameters the function takes
  final List<Token> parameters;
  ///The function body
  final List<Stmt> body;
  FunctionStmt(Token this.name, List<Token> this.parameters, List<Stmt> this.body);
  dynamic accept(StmtVisitor v) => v.visitFunctionStmt(this);

}

class WhileStmt extends Stmt {
  ///while this condition evaluates to True, execute body.
  final Expr condition;
  ///
  final Stmt body;
  WhileStmt(Expr this.condition, Stmt this.body);
  dynamic accept(StmtVisitor v) => v.visitWhileStmt(this);

}

