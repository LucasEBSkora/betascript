import 'BSCalculus/BSCalculus.dart';

int main () {

  Variable x = Variable('x');
  Variable y = Variable('y');

  bscFunction f = log(y,x);
  print(f);
  print(f.derivative(x));

  return 0;
}