import 'BSInterpreter.dart';
import 'BetaScript.dart';
import 'Expr.dart';
import 'Stmt.dart';
import 'Token.dart';

enum FunctionType {
  NONE,
  FUNCTION
}


///This class is used for variable resolution, running between the parser and the intepreter to determine exactly which variable a name refers to
///It does so by determining how many Environments it needs to traverse in order to find the variable to use
///Also used to report semantic errors (such as return statements outside of functions)
class Resolver implements ExprVisitor, StmtVisitor {
  final BSInterpreter _interpreter;
  //Used to see if we're currently traversing a function, which is important to check if a return statement is valid
  FunctionType _currentFunction = FunctionType.NONE;
  


  ///A stack representing Scopes, where the key is the identifier name and the value is wheter it is ready to be referenced
  ///because things like var a = a; should cause compile errors
  final List<Map<String, bool>> _scopes = new List();
  Resolver(this._interpreter);

  //It actually has to do things only in a few cases:

  //Blocks create new scopes
  //funtion declarations create a new scope and bind the parameters to that scope
  //variable declarations add new variables to the current scope
  //variable and assigment expressions need to be resolved

  //for the rest, it is only necessary to traverse to their subtrees

  @override
  void visitAssignExpr(AssignExpr e) {
    _resolveExpr(e.value);
    _resolveLocal(e, e.name);
  }

  @override
  void visitBinaryExpr(BinaryExpr e) {
    _resolveExpr(e.left);
    _resolveExpr(e.right);
  }

  @override
  void visitBlockStmt(BlockStmt s) {
    _beginScope();
    resolveAll(s.statements);
    _endScope();
  }

  @override
  void visitCallExpr(CallExpr e) {
    _resolveExpr(e.callee);

    for (Expr argument in e.arguments) _resolveExpr(argument);
  }

  @override
  void visitExpressionStmt(ExpressionStmt s) {
    _resolveExpr(s.expression);
  }

  @override
  void visitFunctionStmt(FunctionStmt s) {
    //Declares it in current scope, also allowing it to be referenced inside itself for recursiveness
    _declare(s.name);
    _define(s.name);
    _resolveFunction(s, FunctionType.FUNCTION);
  }

  @override
  void visitGroupingExpr(GroupingExpr e) {
    _resolveExpr(e.expression);
  }

  @override
  void visitIfStmt(IfStmt s) {
    //note that here, we evaluate both branches, unlike actual interpreting
    _resolveExpr(s.condition);
    _resolveStmt(s.thenBranch);
    if (s.elseBranch != null) _resolveStmt(s.elseBranch);
  }

  @override
  void visitLiteralExpr(LiteralExpr e) {}

  @override
  void visitPrintStmt(PrintStmt s) {
    _resolveExpr(s.expression);
  }

  @override
  void visitReturnStmt(ReturnStmt s) {
    if (_currentFunction == FunctionType.NONE) BetaScript.error(s.keyword, "Cannot return from top-level code.");
    _resolveExpr(s.value);
  }

  @override
  void visitUnaryExpr(UnaryExpr e) {
    _resolveExpr(e.right);
  }

  @override
  void visitVarStmt(VarStmt s) {
    /*
        var a = 1;
        {
          var a = a;
        }
    
        causes a compile error, because it might be masking a user mistake
    
        */

    _declare(s.name);
    if (s.initializer != null) _resolveExpr(s.initializer);
    _define(s.name);
  }

  @override
  void visitVariableExpr(VariableExpr e) {
    if (!_scopes.isEmpty && _scopes.last[e.name.lexeme] == false) {
      BetaScript.error(
          e.name, "Cannot read local variable in its own initializer");
    }

    _resolveLocal(e, e.name);
    return null;
  }

  @override
  void visitWhileStmt(WhileStmt s) {
    // TODO: implement void visitWhileStmt
    throw UnimplementedError();
  }

  @override
  void visitlogicBinaryExpr(logicBinaryExpr e) {
    _resolveExpr(e.left);
    _resolveExpr(e.right);
  }

  void resolveAll(List<Stmt> statements) {
    for (Stmt s in statements) _resolveStmt(s);
  }

  void _resolveStmt(Stmt s) => s.accept(this);
  void _resolveExpr(Expr e) => e.accept(this);

  void _beginScope() => _scopes.add(new Map());
  void _endScope() => _scopes.removeLast();

  //Creates a variable in current scope without saying it is ready to be referenced
  void _declare(Token name) {
    if (!_scopes.isEmpty) {

      //Variable declared twice - error in functions (honestly should always be error, or variables shouldn't need declaration)
      if (_scopes.last.containsKey(name.lexeme))  BetaScript.error(name, "Variable wit this name already declared in this scope.");
      Map<String, bool> scope = _scopes.last;
      scope[name.lexeme] = false;
    }
  }

  //Marks a variable as ready to be referenced
  void _define(Token name) {
    if (!_scopes.isEmpty) {
      _scopes.last[name.lexeme] = true;
    }
  }

  void _resolveLocal(Expr e, Token name) {
    for (int i = _scopes.length - 1; i >= 0; --i) {
      if (_scopes[i].containsKey(name.lexeme)) {
        _interpreter.resolve(e, _scopes.length - 1 - i);
        return;
      }
    }

    //if the name can't be resolved, it is assumed to be global
  }

  ///Resolves both functions and methods
  void _resolveFunction(FunctionStmt s, FunctionType type) {
    
    //Stores the last function type, because functions can call other functions (or methods)
    FunctionType enclosingFunction = _currentFunction;
    _currentFunction = type;

    _beginScope();
    for (Token param in s.parameters) {
      
      _declare(param);
      _define(param);
    }
    resolveAll(s.body);
    _endScope();
    //Restores the last function type (basically piggybacks on the call stack to simulate a stack)
    _currentFunction = enclosingFunction;
  }
}
