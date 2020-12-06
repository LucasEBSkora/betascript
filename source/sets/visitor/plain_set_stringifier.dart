import '../set_union.dart';
import '../roster_set.dart';
import '../interval.dart';
import '../intensional_set_intersection.dart';
import '../empty_set.dart';
import '../builder_set.dart';
import 'set_visitor.dart';

class PlainSetStringifier extends SetVisitor<String> {
  @override
  String visitBuilderSet(BuilderSet a) =>
      "{" +
      a.rule.parameters
          .reduce((previousValue, element) => "$previousValue, $element") +
      "| ${a.rule}}";

  @override
  String visitEmptySet(EmptySet a) => "∅";

  @override
  String visitIntensionalSetIntersection(IntensionalSetIntersection a) =>
      "(${a.first}) ∩ (${a.second})";

  @override
  String visitInterval(Interval a) =>
      "${(a.leftClosed) ? '[' : '('}${a.a},${a.b}${(a.rightClosed) ? ']' : ')'}";

  @override
  String visitRosterSet(RosterSet a) =>
      a.elements.toList().sublist(1).fold<String>('{${a.elements.first}',
          (previousValue, element) => previousValue + ", $element") +
      '}';

  @override
  String visitSetUnion(SetUnion a) => a.subsets.sublist(1).fold<String>(
      '${a.subsets.first}',
      (previousValue, element) => previousValue + " ∪ $element");
}
