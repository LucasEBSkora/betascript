import 'BSCalculus/BSCalculus.dart';

int main () {

  Variable x = Variable('x');
  Variable y = Variable('y');

  bscFunction f = log(x, y);
  print(f);
  print(f.derivative(x));

  return 0;
}