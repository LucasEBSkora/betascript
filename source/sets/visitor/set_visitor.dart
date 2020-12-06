
import '../empty_set.dart';
import '../sets.dart';

abstract class SetVisitor<ReturnType> {
  const SetVisitor();

  ReturnType visitBuilderSet(BuilderSet a);
  ReturnType visitEmptySet(EmptySet a);
  ReturnType visitIntensionalSetIntersection(IntensionalSetIntersection a);
  ReturnType visitInterval(Interval a);
  ReturnType visitRosterSet(RosterSet a);
  ReturnType visitSetUnion(SetUnion a);
  
}