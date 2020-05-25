import 'dart:io';

import 'BSScanner.dart';
import 'Token.dart';

class BetaScript {
  static bool hadError = false;

  static void runFile(String path) {
    File file = File(path);
    String fileContents = file.readAsStringSync();
    _run(fileContents);

    if (hadError) exit(1);
  }

  static void runPrompt() {
    
    while (true) {
      stdout.write("> ");
      _run(stdin.readLineSync());
      hadError = false;
    }
  }

  static void _run(String source) {
    BSScanner scanner = new BSScanner(source);
    List<Token> tokens = scanner.scanTokens();

    print(tokens);
  }  

  static void error(int line, String message) {
    _report(line, "", message);
  }

  static void _report(int line, String where, String message) {
    print("[line " + line.toString() + "] Error" + where + ": " + message);
    hadError = true;
  }

}