import 'dart:io';

import 'resolver.dart';
import 'token.dart';
import 'βs_interpreter.dart';
import 'βs_parser.dart';
import 'βs_scanner.dart';

class BetaScript {
  static bool hadError = false;
  static bool hadRuntimeError = false;
  static BSInterpreter _interpreter = BSInterpreter();

  ///The callback used when the function 'print' is called. Might print to a string (web version), to a file (not yet implemented) or to the console
  static Function printCallback;

  static void runFile(String path) {
    printCallback = print;
    final file = File(path);
    String fileContents;
    try {
      fileContents = file.readAsStringSync();
    } on FileSystemException catch (e) {
      if (e.osError.errorCode == 2) {
        //no such file or directory
        print("file $path not found!");
        return;
      }
      throw e;
    }
    _run(fileContents);

    if (hadError) exit(1);
    if (hadRuntimeError) exit(2);
  }

  static void runPrompt() {
    printCallback = print;
    while (true) {
      stdout.write("> ");
      _run(stdin.readLineSync());
      hadError = false;
    }
  }

  static String runForWeb(String source) {
    var output = "";

    //resets everything so it always interprets from a fresh start
    hadError = false;
    hadRuntimeError = false;
    _interpreter = BSInterpreter();

    //all print statements redirect to this function, allowing the results to be printed in the 'output' field
    printCallback = (dynamic object) {
      output += object.toString() + '\n';
    };

    _run(source);

    return output;
  }

  static void _run(String source) {
    final scanner = BSScanner(source);
    final tokens = scanner.scanTokens(); //lexical analysis
    // for (Token token in tokens) print(token);
    final parser = BSParser(tokens, _interpreter);
    final statements = parser.parse(); //Syntax analysis
    if (hadError) return;

    final resolver = Resolver(_interpreter);
    resolver.resolveAll(statements); //Semantic analysis

    if (hadError) return;
    _interpreter.interpret(statements);
  }

  static void error(dynamic value, String message) {
    if (value is int) {
      _errorAtLine(value, message);
    } else if (value is Token) {
      _errorAtToken(value, message);
    } else {
      _report(-1, "at unknown location: '${value}'", message);
    }
  }

  static void _errorAtLine(int line, String message) {
    _report(line, "", message);
  }

  static void _errorAtToken(Token token, String message) {
    if (token.type == TokenType.EOF) {
      _report(token.line, " at end", message);
    } else {
      if (token.lexeme == '\n') {
        _report(token.line, " at linebreak ('\\n')", message);
      } else {
        _report(token.line, " at '${token.lexeme}'", message);
      }
    }
  }

  static void _report(int line, String where, String message) {
    printCallback("[Line $line] Error $where: $message");
    hadError = true;
  }

  static void runtimeError(RuntimeError e) {
    printCallback(e);
    hadRuntimeError = true;
  }
}
