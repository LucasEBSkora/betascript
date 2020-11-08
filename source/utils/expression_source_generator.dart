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
    NodeType("Unary", [
      [
        "Token",
        "op",
        "operator (this type is used for unary operators both to the left and to the right)"
      ],
      ["Expr", "operand", "The operand on which the operator is applied"],
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
      ["Token", "keyword", "The token containing the first 'del' keyword"],
      ["Expr", "derivand", "The function whose derivative is being calculated"],
      [
        "List<Expr>",
        "variables",
        "Variables this function is being derivated in"
      ],
    ]),
    NodeType("IntervalDefinition", [
      ["Token", "left", "token containing '[' or '(' "],
      ["Expr", "a", "left bound"],
      ["Expr", "b", "right bound"],
      ["Token", "right", "token containing ']' or ')' "],
    ]),
    NodeType("RosterDefinition", [
      ["Token", "left", "token containing '{' "],
      ["List<Expr>", "elements", "elements of the set"],
      ["Token", "right", "token containing '}' "],
    ]),
    NodeType("BuilderDefinition", [
      ["Token", "left", "token containing '{' "],
      ["List<Token>", "parameters", "parameters used in the rule"],
      ["Expr", "rule", "rule used to test for membership"],
      ["Token", "bar", "token containing '|' "],
      ["Token", "right", "token containing '}' "],
    ]),
    NodeType("SetBinary", [
      ["Expr", "left", "left operand"],
      ["Token", "operator", "token containing operator"],
      ["Expr", "right", "right operand"],
    ]),
  ], [
    'token'
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
      ["Token", "token", "The token containing the while or for keyword"],
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
    NodeType("Directive", [
      ["Token", "token", "Token containing the directive"],
      ["String", "directive", "the directive being issued"],
    ])
  ], [
    'expr',
    'token'
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
  String path = "$outputDir/${fileName.toLowerCase()}.dart";

  File outputFile = File(path);

  String source = "";

  for (String import in imports) {
    source += "import '$import.dart';\n";
  }

  String visitorClassName = fileName + "Visitor";

  source += "\nabstract class $visitorClassName {\n";

  for (NodeType e in types) {
    String className = e.name + fileName;
    source +=
        "  dynamic visit$className($className ${fileName[0].toLowerCase()});\n";
  }

  source += "}\n";

  source +=
      "\nabstract class $fileName {\n  const $fileName();\n  dynamic accept($visitorClassName v);\n}\n\n";

  for (NodeType e in types) {
    String className = e.name + fileName;
    source += "class $className extends $fileName {\n";
    for (List<String> field in e.fields) {
      if (field.length > 2) source += "  ///${field[2]}\n";
      source += "  final ${field[0]} ${field[1]};\n\n";
    }

    source += '  const $className(';
    int i;
    for (i = 0; i < e.fields.length - 1; ++i)
      source += "this.${e.fields[i][1]}, ";

    source += "this.${e.fields[i][1]});\n";

    source +=
        "  dynamic accept($visitorClassName v) => v.visit$className(this);\n";

    source += '}\n\n';
  }

  outputFile.writeAsStringSync(source);

  outputFile.createSync();
}
