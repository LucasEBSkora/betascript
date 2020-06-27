import 'BSInterpreter.dart';
import 'BetaScript.dart';
import 'Expr.dart';
import 'Stmt.dart';
import 'Token.dart';
import 'nativeGlobals.dart';

enum RoutineType { NONE, ROUTINE, INITIALIZER, METHOD }

enum ClassType { NONE, CLASS, SUBCLASS }

///This class is used for variable resolution, running between the parser and the intepreter to determine exactly which variable a name refers to
///It does so by determining how many Environments it needs to traverse in order to find the variable to use
///Also used to report semantic errors (such as return statements outside of routines)
class Resolver implements ExprVisitor, StmtVisitor {
  final BSInterpreter _interpreter;
  //Used to see if we're currently traversing a routine, which is important to check if a return statement is valid
  RoutineType _currentRoutine = RoutineType.NONE;
  ClassType _currentClass = ClassType.NONE;

  ///A stack representing Scopes, where the key is the identifier name and the value is whether it is ready to be referenced
  ///because things like var a = a; should cause compile errors
  final List<Map<String, bool>> _scopes = new List();

  ///Represents all the global values. Used to check if a global is being redefined (to avoid overriding native functions and routines)
  ///Since all native things are already define, they are added to the map from the start
  final Map<String, bool> _globals =
      new Map.fromIterable(nativeGlobals.keys, value: (_) => true);

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
  void visitRoutineStmt(RoutineStmt s) {
    //Declares it in current scope, also allowing it to be referenced inside itself for recursiveness
    _declare(s.name);
    _define(s.name);
    _resolveRoutine(s, RoutineType.ROUTINE);
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
    if (_currentRoutine == RoutineType.NONE)
      BetaScript.error(s.keyword, "Cannot return from top-level code.");
    if (_currentRoutine == RoutineType.INITIALIZER)
      BetaScript.error(s.keyword, "Cannot return a value from a constructor");
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
    //makes sure a variable isn't trying to read itself in its own initialization
    if (!_scopes.isEmpty) {
      if (_scopes.last[e.name.lexeme] == false)
        BetaScript.error(
            e.name, "Cannot read variable in its own initializer");
    } else if (!_globals[e.name.lexeme])
      BetaScript.error(
          e.name, "Cannot read variable in its own initializer");

    _resolveLocal(e, e.name);
  }

  @override
  void visitWhileStmt(WhileStmt s) {
    _resolveExpr(s.condition);
    _resolveStmt(s.body);
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
      //Variable declared twice - error in routines (honestly should always be error, or variables shouldn't need declaration)
      if (_scopes.last.containsKey(name.lexeme))
        BetaScript.error(
            name, "Variable with this name already declared in this scope.");

      _scopes.last[name.lexeme] = false;
    } else {
      if (_globals.containsKey(name.lexeme))
        BetaScript.error(name,
            "Variable with this name already declared in global scope (might be shadowing native declaration).");
      _globals[name.lexeme] = false;
    }
  }

  //Marks a variable as ready to be referenced
  void _define(Token name) {
    if (!_scopes.isEmpty) {
      _scopes.last[name.lexeme] = true;
    } else
      _globals[name.lexeme] = true;
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

  ///Resolves both routines and methods
  void _resolveRoutine(RoutineStmt s, RoutineType type) {
    //Stores the last routine type, because routines can call other routines (or methods)
    RoutineType enclosingRoutine = _currentRoutine;
    _currentRoutine = type;

    _beginScope();
    for (Token param in s.parameters) {
      _declare(param);
      _define(param);
    }
    resolveAll(s.body);
    _endScope();
    //Restores the last routine type (basically piggybacks on the call stack to simulate a stack)
    _currentRoutine = enclosingRoutine;
  }

  @override
  void visitClassStmt(ClassStmt s) {
    ClassType enclosingClass = _currentClass;
    _currentClass = ClassType.CLASS;

    _declare(s.name);
    _define(s.name);

    if (s.superclass != null) {
      if (s.name.lexeme == s.superclass.name.lexeme)
        BetaScript.error(
            s.superclass.name, "A class cannot inherit from itself");

      _currentClass = ClassType.SUBCLASS;
      _resolveExpr(s.superclass);

      //Creates a new closure containing super, which contains all the methods
      _beginScope();
      _scopes.last["super"] = true;
    }

    _beginScope();
    _scopes.last["this"] = true;
    for (RoutineStmt method in s.methods) {
      RoutineType declaration = (method.name.lexeme == s.name.lexeme)
          ? RoutineType.INITIALIZER
          : RoutineType.METHOD;
      _resolveRoutine(method, declaration);
    }

    _endScope();

    if (s.superclass != null) _endScope();

    _currentClass = enclosingClass;
  }

  @override
  void visitGetExpr(GetExpr e) {
    _resolveExpr(e.object);
  }

  @override
  void visitSetExpr(SetExpr e) {
    _resolveExpr(e.value);
    _resolveExpr(e.object);
  }

  @override
  visitThisExpr(ThisExpr e) {
    if (_currentClass == ClassType.NONE) {
      BetaScript.error(e.keyword, "Cannot use 'this' outside of a class");
    }
    _resolveLocal(e, e.keyword);
  }

  @override
  void visitSuperExpr(SuperExpr e) {
    if (_currentClass == ClassType.NONE)
      BetaScript.error(e.keyword, "Cannot use 'super' outside of a class.");
    else if (_currentClass != ClassType.SUBCLASS)
      BetaScript.error(
          e.keyword, "Cannot use 'super' in a class with no superclass");
    _resolveLocal(e, e.keyword);
  }
}
