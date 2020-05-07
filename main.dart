import 'BSCalculus/BSCalculus.dart';

int main () {

  Variable x = Variable('x');
  Variable y = Variable('y');

  bscFunction f = x/y;

  print(f);
  print(f.derivative(x));
  print(f.derivative(y));
  return 0;
}