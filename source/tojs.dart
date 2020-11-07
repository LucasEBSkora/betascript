//Entry point for the web version of the interpreter

import 'dart:html';

import 'interpreter/βscript.dart';

int main() {
  // File file = File();
  // File file = File("example.bs");
  // String contents = file.readAsStringSync();

  String contents = """
let f(x) = sin(x)
  
let g = f(cos(x))
  
print g

print f + g

print e^x

let h(x, y, z) = 0

print h(1, 2, arcosh(z))

let i(y,x) = pi + 2 - log(y, 33)*sec(y/x)
print i(11, 2)
print ~i(11, 2)

let j(x, y, z) = x^2*y^3

print del(j)/del(x, y, x)

let A = {x | x > 2}
let B = [-10, 5)
print A union B
print A\\B
print A contained B
print A'
""";
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
