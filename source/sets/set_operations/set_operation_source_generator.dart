import 'dart:io';

void main() {
  String path = "set_operation.dart";

  File outputFile = File(path);

  String source = "";

  const classes = <String>[
    'BuilderSet',
    'IntensionalSetIntersection',
    'Interval',
    'RosterSet',
    'SetUnion'
  ];

  for (String import in <String>[
    'package:meta/meta',
    '../../utils/method_table',
    '../sets',
    '../empty_set'
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
  source +=
      '  ReturnType call(BSSet first, BSSet second) => _methodTable(first, second);\n\n';
  for (final type1 in classes)
    for (final type2 in classes) {
      source += '  @visibleForOverriding\n'
          '  ReturnType operate$type1$type2($type1 first, $type2 second);\n\n';
    }

  source += '}\n\n';

  source += """abstract class EmptyFilteringSetOperation<ReturnType>
    extends SetOperation<ReturnType> {
  EmptyFilteringSetOperation() : super();

  @override
  ReturnType call(BSSet first, BSSet second) =>
      ((first == emptySet) || (second == emptySet))
          ? onEmpty(first, second)
          : _methodTable(first, second);

  @visibleForOverriding
  ReturnType onEmpty(BSSet first, BSSet second);
}\n\n""";

  source += """abstract class EmptyTreatingSetOperation<ReturnType>
    extends SetOperation<ReturnType> {
  EmptyTreatingSetOperation() : super() {\n""";
  for (final type in classes) {
    source +=
        '    _methodTable.addMethod($type, EmptySet, operate${type}EmptySet);\n'
        '    _methodTable.addMethod(EmptySet, $type, operateEmptySet${type});\n';
  }
  source +=
      '    _methodTable.addMethod(EmptySet, EmptySet, operateEmptySetEmptySet);\n'
      '}\n\n';

  for (final type in classes) {
    source += '  @visibleForOverriding\n'
        '  ReturnType operate${type}EmptySet($type first, EmptySet second);\n\n';
    source += '  @visibleForOverriding\n'
        '  ReturnType operateEmptySet${type}(EmptySet first, $type  second);\n\n';
  }
  source += '  @visibleForOverriding\n'
      '  ReturnType operateEmptySetEmptySet(EmptySet first, EmptySet second);\n\n'
      '}\n\n';

  source +=
      'abstract class EmptyFilteringComutativeSetOperation<ReturnType> extends EmptyFilteringSetOperation<ReturnType> {\n'
      '  EmptyFilteringComutativeSetOperation() : super();\n\n';

  for (var i = 0; i < classes.length; ++i)
    for (var j = i + 1; j < classes.length; ++j) {
      final type1 = classes[i];
      final type2 = classes[j];
      source += '  @override\n  @nonVirtual\n'
          '  ReturnType operate$type1$type2($type1 first, $type2 second) =>\n    operate$type2$type1(second, first);\n\n';
    }

  source += '}\n\n';

  source +=
      'abstract class EmptyTreatingComutativeSetOperation<ReturnType> extends EmptyTreatingSetOperation<ReturnType> {\n'
      '  EmptyTreatingComutativeSetOperation() : super();\n';

  const List<String> classesWithEmpty = ["EmptySet", ...classes];

  for (var i = 0; i < classesWithEmpty.length; ++i)
    for (var j = i + 1; j < classesWithEmpty.length; ++j) {
      final type1 = classesWithEmpty[i];
      final type2 = classesWithEmpty[j];
      source += '  @override\n  @nonVirtual\n'
          '  ReturnType operate$type1$type2($type1 first, $type2 second) =>\n    operate$type2$type1(second, first);\n\n';
    }

  source += '}\n\n';

  outputFile.writeAsStringSync(source);

  outputFile.createSync();
}
