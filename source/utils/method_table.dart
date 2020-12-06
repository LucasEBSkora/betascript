import 'dart:collection' show HashMap;

import 'package:meta/meta.dart';

///Used to store operations between subtypes of a type
class MethodTable<R, D> {
  @protected
  final HashMap<String, Function> hashMap = HashMap();

  MethodTable();

  //Can't really stop anyone from adding a type which doesn't extend D
  //or a method which isn't defined in two D variables or doesn't return R
  void addMethod(Type t1, Type t2, Function method) =>
      hashMap[t1.toString() + t2.toString()] = method;

  R call(D first, D second) =>
      findMethod(first.runtimeType, second.runtimeType)(first, second);

  ///adds the same method for many cells in the same line
  void addMethodsInLine(Type t1, List<Type> t2, Function method) =>
      t2.forEach((element) => addMethod(t1, element, method));

  ///adds the same method for many cells in the same column
  void addMethodsInColumn(List<Type> t1, Type t2, Function method) =>
      t1.forEach((element) => addMethod(element, t2, method));

  @protected
  Function findMethod(Type t1, Type t2) {
    try {
      return hashMap[t1.toString() + t2.toString()];
    } catch (e) {
      if (!hashMap.containsKey(t1.toString() + t2.toString())) {
        throw UnimplementedError();
      } else {
        rethrow;
      }
    }
  }
}
