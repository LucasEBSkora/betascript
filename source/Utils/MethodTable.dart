import 'dart:collection' show HashMap;

import 'package:meta/meta.dart';

///Used to effitiently store operations between subtypes of a type
class MethodTable<RETURN_TYPE, DATA_TYPE> {
  @protected
  final HashMap<String, Function> hashMap = HashMap();

  MethodTable();

  //Can't really stop anyone from adding a type which doesn't extend DATA_TYPE
  //or a method which isn't defined in two DATA_TYPE variables or doesn't return RETURN_TYPE
  void addMethod(Type t1, Type t2, Function method) =>
      hashMap[t1.toString() + t2.toString()] = method;

  RETURN_TYPE call(DATA_TYPE first, DATA_TYPE second) =>
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
      if (!hashMap.containsKey(t1.toString() + t2.toString()))
        throw UnimplementedError();
      else
        throw e;
    }
  }
}

class ComutativeMethodTable<RETURN_TYPE, DATA_TYPE>
    extends MethodTable<RETURN_TYPE, DATA_TYPE> {
  @override
  void addMethod(Type t1, Type t2, Function method) =>
      hashMap[_getStringConversion(t1, t2)] = method;

  @protected
  Function findMethod(Type t1, Type t2) {
    try {
      return hashMap[_getStringConversion(t1, t2)];
    } catch (e) {
      if (!hashMap.containsKey(_getStringConversion(t1, t2)))
        throw UnimplementedError();
      else
        throw e;
    }
  }

  String _getStringConversion(Type t1, Type t2) {
    if (t1.toString().compareTo(t2.toString()) <= 0)
      return t1.toString() + t2.toString();
    else
      return t2.toString() + t1.toString();
  }
}
