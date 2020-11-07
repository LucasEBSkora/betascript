import 'βs_function/βs_calculus.dart';
import 'sets/sets.dart';
import 'logic/logic.dart';

void main() {
  Variable x = variable("x");
  Variable y = variable("y");
  Variable z = variable("z");

  BSFunction f = tan(y - x) * z;
  BSFunction g = f([arctan(x), sin(n(0.5)), n(1) / n(2)]);
  BSFunction h = f.withParameters(Set.from([z, y, x]));
  BSFunction i = h([arctan(x), sin(n(0.5)), n(4) / n(2)]);

  print(f);
  print(f.parameters);
  print(g);
  print(h);
  print(i);

  BSFunction j = x / y + (-x) / y + x / (-y) + (-x) / (-y);
  print(j);

  Type t = BSFunction;
  print(j.runtimeType.toString());

  print(t == j.runtimeType);

  BSSet first = interval(n(13), n(14), leftClosed: true, rightClosed: false);

  print(first);
  print(first.belongs(n(13)));
  print(first.belongs(n(14)));

  print(interval(n(14), n(14), leftClosed: false));

  BSSet second = interval(n(13), n(13.5));

  print(second);
  print(second.contains(first));
  print(first.relativeComplement(second));

  print(first.disjoined(second));

  second = interval(n(-1), n(0));

  print(second);
  print(second.contains(first));
  print(first.relativeComplement(second));

  print(second.union(first));

  print(second.union(first).union(Interval.closed(n(-1), n(13))));

  print(first.disjoined(second));

  RosterSet roster = rosterSet([n(14), constants.pi, n(0)]);

  print(roster);

  BSSet third = first.union(second);
  print(third);
  print(first.union(second).union(roster));
  print(first.union(roster));

  BSSet many = Interval.closed(n(-10), n(9))
      .union(Interval.closed(n(-1000), n(-999.99)))
      .union(Interval.closed(n(-900), n(-100)));

  print(third.union(many));

  LogicExpression e1 = Or(LessOrEqual(-x + n(3), n(0)), Equal(x, n(0)));
  print(e1);
  print(e1.solution);
}
