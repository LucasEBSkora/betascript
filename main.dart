import 'BSCalculus/BSCalculus.dart';

int main () {

  Variable x = Variable('x');
  Variable y = Variable('y');

  bscFunction f = log(x, y);
  print(f({'x': 4, 'y': 2}));
  print(f);
  print(f.derivative(x));

  return 0;
}