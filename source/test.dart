import 'BSFunction/BSCalculus.dart';

void main() {
  Variable x = variable("x");
  Variable y = variable("y");
  Variable z = variable("z");

  BSFunction f = tan(y + x) * z;
  BSFunction g = f([arctan(x), sin(n(0.5)), n(1) / n(2)]);
  BSFunction h = f.withParameters(Set.from([z, y, x]));
  BSFunction i = h([arctan(x), sin(n(0.5)), n(1) / n(2)]);

  print(f);
  print(f.parameters);
  print(g);
  print(h);
  print(i);
}
