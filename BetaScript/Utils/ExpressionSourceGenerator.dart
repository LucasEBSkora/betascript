import 'dart:io';

//a helper program that generates a valid dart file with the classes representing each type of expression, for use in ASTs.
int main() {
  defineAst("..", "Expr", [
    NodeType(
      "Binary",
      [
        ["Expr", "left", "operand to the left of the operator"],
        ["Token", "op", "operator"],
        ["Expr", "right", "operand to the right of the operator"],
      ],
    ),
    NodeType( "Call", [
      ["Expr", "callee", "The function being called"],
      ["Token", "paren", "The parentheses token"],
      ["List<Expr>", "arguments", "The list of arguments being passed"],
    ]
    ),
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
    NodeType("Assign", [
      ["Token", "name", "The name of the variable being assigned to"],
      [
        "Expr",
        "value",
        "The expression whose result should be assigned to the variable"
      ],
    ]),
    NodeType(
      "logicBinary",
      [
        ["Expr", "left", "operand to the left of the operator"],
        ["Token", "op", "operator"],
        ["Expr", "right", "operand to the right of the operator"],
      ],
    ),
  ], [
    'Token'
  ]);

  defineAst("..", "Stmt", [
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
    NodeType("Function", [
      ["Token", "name", "The function's name"],
      ["List<Token>", "parameters", "The parameters the function takes"],
      ["List<Stmt>", "body", "The function body"],
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
  String path = outputDir + '/' + fileName + '.dart';

  File outputFile = File(path);

  String source = "";

  for (String i in imports) {
    source += "import '" + i + ".dart';";
  }

  String visitorClassName = fileName + "Visitor";

  source += "\nabstract class " + visitorClassName + " {\n";

  for (NodeType e in types) {
    source += '  dynamic visit' +
        e.name +
        fileName +
        '(' +
        e.name +
        fileName +
        ' ' +
        fileName[0].toLowerCase() +
        ');\n';
  }

  source += "\n}\n";

  source += "\nabstract class " +
      fileName +
      "  {\n" +
      "  dynamic accept(" +
      visitorClassName +
      " v);\n" +
      "\n}\n\n";

  for (NodeType e in types) {
    source += "class " + e.name + fileName + " extends " + fileName + " {\n";
    for (List<String> field in e.fields) {
      if (field.length > 1) source += "  ///" + field[2] + '\n';
      source += "  final " + field[0] + ' ' + field[1] + ';\n';
    }

    source += '  ' + e.name + fileName + '(';
    int i;
    for (i = 0; i < e.fields.length - 1; ++i) {
      source += e.fields[i][0] + ' this.' + e.fields[i][1] + ', ';
    }

    source += e.fields[i][0] + ' this.' + e.fields[i][1] + ');\n';
    source += "  dynamic accept(" +
        visitorClassName +
        " v) => v.visit" +
        e.name +
        fileName +
        "(this);\n";

    source += '\n}\n\n';
  }

  outputFile.writeAsStringSync(source);

  outputFile.createSync();
}
