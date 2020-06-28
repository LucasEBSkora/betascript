//Entry point for the web version of the interpreter

import 'dart:html';

import 'interpreter/BetaScript.dart';

int main() {
  // File file = File();
  // File file = File("example.bs");
  // String contents = file.readAsStringSync();

  String contents =
  //     'class A {\n  method() {\n    print "a method";\n  }\n}\n\nclass B < A {\n  method() {\n    print "B method";\n  }\n\n  test() {\n    super.method();\n  }\n}\n\nclass C < B {\n  C(callback) {\n    this.callback = callback;\n  }\n\n  callCallback() {\n    this.callback();\n  }\n}\n\nfunction printStuff() {\n  print "stu" + "ff";\n}\n\nvar thing = C(printStuff);\n\nthing.test();\nthing.method();\nthing.callCallback();';
  "let f(x) = sin(x);\n\nlet g = f(cos(x));\n\nprint g;\n\nprint f + g;\n\nprint e^x;\n\nlet h(x, y, z) = 0;\n\nprint h(1, 2, arcosh(z));\n\nlet i(y,x) = pi + 2 - log(y, 33)*sec(y/x);\nprint i(11, 2);";
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
