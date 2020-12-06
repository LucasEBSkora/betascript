import 'dart:io';

void main() {
  String path = "set_operation.dart";

  File outputFile = File(path);

  String source = "";

  const classes = <String>[
    'BuilderSet',
    'EmptySet',
    'IntensionalSetIntersection',
    'Interval',
    'RosterSet',
    'SetUnion'
  ];

  for (String import in <String>[
    'package:meta/meta',
    '../../utils/method_table',
    '../set',
    '../builder_set',
    '../empty_set',
    '../intensional_set_intersection',
    '../interval',
    '../roster_set',
    '../set_union'
  ]) {
    source += "import '$import.dart';\n";
  }

  source += '\n\nabstract class SetOperation<ReturnType> {'
      '\n\n  final MethodTable _methodTable = MethodTable<ReturnType, BSSet>();\n'
      '\n  SetOperation() {\n';
  for (final type1 in classes)
    for (final type2 in classes) {
      source +=
          '    _methodTable.addMethod($type1, $type2, operate$type1$type2);\n';
    }
  source += '\n';
  source += '  }\n\n';
  source += '  ReturnType call(BSSet first, BSSet second) => _methodTable(first, second);';
  for (final type1 in classes)
    for (final type2 in classes) {
      source += '  @visibleForOverriding\n'
          '  ReturnType operate$type1$type2($type1 first, $type2 second);\n\n';
    }

  source += '}\n\n';

  source +=
      'abstract class ComutativeSetOperation<ReturnType> extends SetOperation<ReturnType> {\n'
      '  ComutativeSetOperation() : super();\n';

  for (var i = 0; i < classes.length; ++i)
    for (var j = i + 1; j < classes.length; ++j) {
      final type1 = classes[i];
      final type2 = classes[j];
      source += '  @override\n  @nonVirtual\n'
          '  ReturnType operate$type1$type2($type1 first, $type2 second) =>\n    operate$type2$type1(second, first);\n\n';
    }

  source += '}\n\n';

  outputFile.writeAsStringSync(source);

  outputFile.createSync();
}
