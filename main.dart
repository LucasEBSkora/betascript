import 'BSCalculus/BSCalculus.dart';

int main () {

  Variable x = Variable('x');
  Variable y = Variable('y');

  bscFunction f = log(x, y);
  print(f.derivative(x));
  // print((Number.e^x).derivative(x));
  // print((y^Number(2)).derivative(y));
  return 0;
}