import 'dart:io';
import 'BetaScript/BetaScript.dart';
int main (List<String> args) {


  if (args.length > 1) {
    print("usage: bs [script]");
    exit(1);
  } else if (args.length == 1) {
    BetaScript.runFile(args[0]);
  } else {
    BetaScript.runPrompt();
  }
  return 0;
}

