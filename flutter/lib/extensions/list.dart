import 'package:flutter/material.dart';

extension WListT<T> on List<T> {
  List<T> multiple(int count) {
    return List<T>.generate(count, (index) => this[index % length]);
  }
}

extension WListExt on List<Widget> {
  List<Widget> withSeparator(Widget separator) {
    if (isEmpty) return [];
    final List<Widget> separatedList = [];
    for (var i = 0; i < length; i++) {
      separatedList.add(this[i]);
      if (i < length - 1) {
        separatedList.add(separator);
      }
    }
    return separatedList;
  }
}
