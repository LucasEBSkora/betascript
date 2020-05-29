import 'dart:io';

//a helper program that generates a valid dart file with the classes representing each type of expression, for use in ASTs.
int main() {
  defineAst("..", "Expr", [
    ExpressionType(
      "Binary",
      [
        ["Expr", "left", "operand to the left of the operator"],
        ["Token", "op", "operator"],
        ["Expr", "right", "operand to the right of the operator"]
      ],
    ),
    ExpressionType("Grouping", [
      [
        "Expr", "expression",
        "A grouping is a collection of other Expressions, so it holds only another expression."
      ]
    ]),
    ExpressionType("Literal", [
      [
        "dynamic", "value",
        "Literals are numbers, strings, booleans or null. This field holds one of them."
      ]
    ]),
    //TODO: fix unary so it can be to the left (the factorial sign is placed after the operand.)
    ExpressionType("Unary", [
      ["Token", "op", "operator"],
      ["Expr", "right", "all Unary operators have the operand to their right."]
    ])
  ], ['Token']);


  defineAst("..", "Stmt", [
    ExpressionType("Expression", [
      ["Expr", "expression",  "Expression statements are basically wrappers for Expressions"]
    ]),
    ExpressionType("Print", [
      ["Expr", "expression", "print statements evaluate and then print their expressions"]
    ])
  ], ['Expr']);
  return 0;
}

class ExpressionType {
  final name;
  final List<List<String>> fields;

  ExpressionType(this.name, this.fields);
}

void defineAst(String outputDir, String fileName, List<ExpressionType> types, List<String> imports) {
  String path = outputDir + '/' + fileName + '.dart';

  File outputFile = File(path);

  
  String source = "";

  for (String i in imports) {
    source += "import '" + i + ".dart';";
  }

  String visitorClassName = fileName + "Visitor";
  
  source += "\nabstract class " +  visitorClassName + " {\n";

  for (ExpressionType e in types) {
    source += '  dynamic visit' + e.name + fileName + '(' + fileName + ' ' + fileName[0].toLowerCase() + ');\n';
  }
  
  
  source += "\n}\n";
  
  source += "\nabstract class " + fileName + "  {\n" +
  "  dynamic accept(" +  visitorClassName + " v);\n"+ 
  "\n}\n\n";

  for (ExpressionType e in types) {
    source += "class " + e.name + fileName + " extends " + fileName + " {\n";
    for (List<String> field in e.fields) {
      if (field.length > 1) source += "  ///" + field[2] + '\n';
      source += "  final " + field[0] + ' ' + field[1] +';\n';

    }

      source += '  ' + e.name + fileName + '(';
    int i;
    for (i = 0; i < e.fields.length - 1; ++i) {
      source += e.fields[i][0] + ' this.' + e.fields[i][1] + ', ';
    }

    source += e.fields[i][0] + ' this.' + e.fields[i][1] + ');\n';
    source += "  dynamic accept(" + visitorClassName + " v) => v.visit" + e.name + fileName + "(this);\n";

    source += '\n}\n\n';
  }

  outputFile.writeAsStringSync(source);

  outputFile.createSync();

}
