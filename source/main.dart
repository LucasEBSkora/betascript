import 'interpreter/betascript.dart';

//main function for the command line version
int main(List<String> args) {
  if (args.length > 1) {
    print("usage: bs [script]");
    return 1;
  } else if (args.length == 1) {
    BetaScript.runFile(args[0]);
  } else {
    BetaScript.runPrompt();
  }
  return 0;
}
