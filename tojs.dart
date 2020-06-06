//Entry point for the web version of the interpreter

import 'dart:html';

import 'BetaScript/BetaScript.dart';

int main() {
  
  // File file = File();
  // File file = File("example.bs");
  // String contents = file.readAsStringSync();

  String contents = 'class A {\n  method() {\n    print "a method";\n  }\n}\n\nclass B < A {\n  method() {\n    print "B method";\n  }\n\n  test() {\n    super.method();\n  }\n}\n\nclass C < B {\n  C(callback) {\n    this.callback = callback;\n  }\n\n  callCallback() {\n    this.callback();\n  }\n}\n\nfunction printStuff() {\n  print "stu" + "ff";\n}\n\nvar thing = C(printStuff);\n\nthing.test();\nthing.method();\nthing.callCallback();';
  (document.getElementById("source") as TextAreaElement).value = contents;

  //Sets a listener for "interpretButton", which gets the text in the textarea "source", runs it through the interpreter and writes the
  //results to the "output" textarea
  document.getElementById("interpretButton").onClick.listen((event) {
    TextAreaElement output = document.getElementById("output");
    TextAreaElement source = document.getElementById("source");
    output.value = BetaScript.runForWeb(source.value);
  });

  return 0;
}
