import 'BSCalculus/BSCalculus.dart';

int main () {

  Variable x = Variable('x');
  Variable y = Variable('y');

  bscFunction f = Number(-1)*x + Number(-1) + y;

  print(f);
  print((-1).abs().toString());
  return 0;
}