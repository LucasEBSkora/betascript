import 'BSFunction/BSCalculus.dart';

void main() {
  Variable x = variable("x");
  Variable y = variable("y");
  Variable z = variable("z");
  
  BSFunction f = tan(x + y)*z;
  BSFunction g = n(1);
  BSFunction h = x^n(44);


  print("$f: ${f.parameters}");
  print("$g: ${g.parameters}");
  print("$h: ${h.parameters}");

}