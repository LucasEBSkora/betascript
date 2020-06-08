import 'BSFunction/BSCalculus.dart';

void main() {
  Variable x = variable("x");
  Variable y = variable("y");
  Variable z = variable("z");
  
  bscFunction f = sin(x + y)*z;
  bscFunction g = n(1);
  bscFunction h = x^n(44);


  print("$f: ${f.parameters}");
  print("$g: ${g.parameters}");
  print("$h: ${h.parameters}");

}