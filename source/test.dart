import 'logic/logic.dart';
import 'sets/sets.dart';
import 'function/functions.dart';

void main() {
  final x = variable("x");
  final y = variable("y");
  final z = variable("z");

  final f = tan(y - x) * z;
  final g = f([arctan(x), sin(n(0.5)), n(1) / n(2)]);
  final h = f.withParameters(<Variable>{z, y, x});
  final i = h([arctan(x), sin(n(0.5)), n(4) / n(2)]);

  print(f);
  print(f.parameters);
  print(g);
  print(h);
  print(i);

  final j = x / y + (-x) / y + x / (-y) + (-x) / (-y);
  print(j);

  final t = BSFunction;
  print(j.runtimeType.toString());

  print(t == j.runtimeType);

  final first = interval(n(13), n(14), leftClosed: true, rightClosed: false);

  print(first);
  print(first.belongs(n(13)));
  print(first.belongs(n(14)));

  print(interval(n(14), n(14), leftClosed: false));

  var second = interval(n(13), n(13.5));

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

  final roster = rosterSet([n(14), Constants.pi, n(0)]);

  print(roster);

  final third = first.union(second);
  print(third);
  print(first.union(second).union(roster));
  print(first.union(roster));

  final many = Interval.closed(n(-10), n(9))
      .union(Interval.closed(n(-1000), n(-999.99)))
      .union(Interval.closed(n(-900), n(-100)));

  print(third.union(many));

  final e1 = Or(LessOrEqual(-x + n(3), n(0)), Equal(x, n(0)));
  print(e1);
  print(e1.solution);
}
