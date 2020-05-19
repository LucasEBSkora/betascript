import 'BSCalculus/BSCalculus.dart';

int main () {

  Variable x = variable('x');
  Variable y = variable('y');

  bscFunction f = (x^n(2)) + log(abs(cos(x)), arcsec(y))/n(27);
  print(f({'x': 4, 'y': 2}));
  print(f);
  print(f.derivative(x));

  return 0;
}