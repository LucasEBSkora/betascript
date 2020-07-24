import 'Expr.dart';import 'Token.dart';
abstract class StmtVisitor {
  dynamic visitExpressionStmt(ExpressionStmt s);
  dynamic visitPrintStmt(PrintStmt s);
  dynamic visitVarStmt(VarStmt s);
  dynamic visitBlockStmt(BlockStmt s);
  dynamic visitIfStmt(IfStmt s);
  dynamic visitRoutineStmt(RoutineStmt s);
  dynamic visitWhileStmt(WhileStmt s);
  dynamic visitReturnStmt(ReturnStmt s);
  dynamic visitClassStmt(ClassStmt s);
  dynamic visitDirectiveStmt(DirectiveStmt s);

}

abstract class Stmt {
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
  ///for functions, the list of variables it is defined in
  final List<Token> parameters;
  ///If the variable is initialized on declaration, the inicializer is stored here
  final Expr initializer;
  VarStmt(Token this.name, List<Token> this.parameters, Expr this.initializer);
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

class RoutineStmt extends Stmt {
  ///The routine's name
  final Token name;
  ///The parameters the routine takes
  final List<Token> parameters;
  ///The routine body
  final List<Stmt> body;
  RoutineStmt(Token this.name, List<Token> this.parameters, List<Stmt> this.body);
 dynamic accept(StmtVisitor v) => v.visitRoutineStmt(this);

}

class WhileStmt extends Stmt {
  ///The token containing the while or for keyword
  final Token token;
  ///while this condition evaluates to True, execute body.
  final Expr condition;
  ///
  final Stmt body;
  WhileStmt(Token this.token, Expr this.condition, Stmt this.body);
 dynamic accept(StmtVisitor v) => v.visitWhileStmt(this);

}

class ReturnStmt extends Stmt {
  ///The token containing the keyword 'return'
  final Token keyword;
  ///The expression whose value should be returned
  final Expr value;
  ReturnStmt(Token this.keyword, Expr this.value);
 dynamic accept(StmtVisitor v) => v.visitReturnStmt(this);

}

class ClassStmt extends Stmt {
  ///Token containing the class' name
  final Token name;
  ///A variable containing a reference to the superclass
  final VariableExpr superclass;
  ///A list of the class' methods
  final List<RoutineStmt> methods;
  ClassStmt(Token this.name, VariableExpr this.superclass, List<RoutineStmt> this.methods);
 dynamic accept(StmtVisitor v) => v.visitClassStmt(this);

}

class DirectiveStmt extends Stmt {
  ///Token containing the directive
  final Token token;
  ///the directive being issued
  final String directive;
  DirectiveStmt(Token this.token, String this.directive);
 dynamic accept(StmtVisitor v) => v.visitDirectiveStmt(this);

}

