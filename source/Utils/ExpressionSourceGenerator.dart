import 'dart:io';

//a helper program that generates valid dart files with the classes representing each type of Expression and Statement, for use in ASTs.
int main() {
  defineAst("../interpreter", "Expr", [
    NodeType("Assign", [
      ["Token", "name", "The name of the variable being assigned to"],
      [
        "Expr",
        "value",
        "The expression whose result should be assigned to the variable"
      ],
    ]),
    NodeType(
      "Binary",
      [
        ["Expr", "left", "operand to the left of the operator"],
        ["Token", "op", "operator"],
        ["Expr", "right", "operand to the right of the operator"],
      ],
    ),
    NodeType("Call", [
      ["Expr", "callee", "The routine/function/method being called"],
      ["Token", "paren", "The parentheses token"],
      ["List<Expr>", "arguments", "The list of arguments being passed"],
    ]),
    NodeType("Get", [
      ["Expr", "object", "The object whose field is being accessed"],
      ["Token", "name", "The field being accessed"],
    ]),
    NodeType("Grouping", [
      [
        "Expr",
        "expression",
        "A grouping is a collection of other Expressions, so it holds only another expression."
      ],
    ]),
    NodeType("Literal", [
      [
        "dynamic",
        "value",
        "Literals are numbers, strings, booleans or null. This field holds one of them."
      ],
    ]),
    //TODO: fix unary so it can be to the left (the factorial sign is placed after the operand.)
    NodeType("Unary", [
      ["Token", "op", "operator"],
      ["Expr", "right", "all Unary operators have the operand to their right."],
    ]),
    NodeType("Variable", [
      ["Token", "name", "The token containing the variable's name"],
    ]),

    NodeType(
      "logicBinary",
      [
        ["Expr", "left", "operand to the left of the operator"],
        ["Token", "op", "operator"],
        ["Expr", "right", "operand to the right of the operator"],
      ],
    ),
    NodeType("Set", [
      ["Expr", "object", "Object whose field is being set"],
      ["Token", "name", "name of the field being set"],
      ["Expr", "value", "The value being assigned to the field"]
    ]),
    NodeType("This", [
      ["Token", "keyword", "The token containing the keyword 'this'"],
    ]),
    NodeType("Super", [
      ["Token", "keyword", "The token containing the keyword 'super'"],
      ["Token", "method", "The method being accessed"],
    ]),
    NodeType("Derivative", [
      ["Token", "keyword","The token containing the first 'del' keyword"],
      ["Expr", "derivand", "The function whose derivative is being calculated"], 
      ["List<Expr>", "variables", "Variables this function is being derivated in"],
    ]),
  ], [
    'Token'
  ]);

  defineAst("../interpreter", "Stmt", [
    NodeType("Expression", [
      [
        "Expr",
        "expression",
        "Expression statements are basically wrappers for Expressions"
      ]
    ]),
    NodeType("Print", [
      [
        "Expr",
        "expression",
        "print statements evaluate and then print their expressions"
      ]
    ]),
    NodeType("Var", [
      ["Token", "name", "The token holding the variable's name"],
      [
        "List<Token>",
        "parameters",
        "for functions, the list of variables it is defined in"
      ],
      [
        "Expr",
        "initializer",
        "If the variable is initialized on declaration, the inicializer is stored here"
      ],
    ]),
    NodeType("Block", [
      [
        "List<Stmt>",
        "statements",
        "A block contains a sequence of Statements, being basically a region of code with specific scope"
      ]
    ]),
    NodeType("If", [
      [
        "Expr",
        "condition",
        "If this condition evaluates to True, execute ThenBranch. If it doesn't, execute elseBranch"
      ],
      ["Stmt", "thenBranch", ""],
      ["Stmt", "elseBranch", ""],
    ]),
    NodeType("Routine", [
      ["Token", "name", "The routine's name"],
      ["List<Token>", "parameters", "The parameters the routine takes"],
      ["List<Stmt>", "body", "The routine body"],
    ]),
    NodeType("While", [
      [
        "Expr",
        "condition",
        "while this condition evaluates to True, execute body."
      ],
      ["Stmt", "body", ""],
    ]),
    NodeType("Return", [
      ["Token", "keyword", "The token containing the keyword 'return'"],
      ["Expr", "value", "The expression whose value should be returned"],
    ]),
    NodeType("Class", [
      ["Token", "name", "Token containing the class' name"],
      [
        "VariableExpr",
        "superclass",
        "A variable containing a reference to the superclass"
      ],
      ["List<RoutineStmt>", "methods", "A list of the class' methods"],
    ]),
  ], [
    'Expr',
    'Token'
  ]);
  return 0;
}

class NodeType {
  final name;
  final List<List<String>> fields;

  NodeType(this.name, this.fields);
}

void defineAst(String outputDir, String fileName, List<NodeType> types,
    List<String> imports) {
  String path = "$outputDir/$fileName.dart";

  File outputFile = File(path);

  String source = "";

  for (String import in imports) {
    source += "import '$import.dart';";
  }

  String visitorClassName = fileName + "Visitor";

  source += "\nabstract class $visitorClassName {\n";

  for (NodeType e in types) {
    String className = e.name + fileName;
    source +=
        "  dynamic visit$className($className ${fileName[0].toLowerCase()});\n";
  }

  source += "\n}\n";

  source +=
      "\nabstract class $fileName {\n dynamic accept($visitorClassName v);\n}\n\n";

  for (NodeType e in types) {
    String className = e.name + fileName;
    source += "class $className extends $fileName {\n";
    for (List<String> field in e.fields) {
      if (field.length > 2) source += "  ///${field[2]}\n";
      source += "  final ${field[0]} ${field[1]};\n";
    }

    source += '  $className(';
    int i;
    for (i = 0; i < e.fields.length - 1; ++i)
      source += "${e.fields[i][0]} this.${e.fields[i][1]}, ";

    source += "${e.fields[i][0]} this.${e.fields[i][1]});\n";

    source +=
        " dynamic accept($visitorClassName v) => v.visit$className(this);\n";

    source += '\n}\n\n';
  }

  outputFile.writeAsStringSync(source);

  outputFile.createSync();
}
