import 'package:flutter/material.dart';

class ExpandedIf extends StatelessWidget {
  final Widget child;
  final bool expand;
  final int flex;
  const ExpandedIf({
    super.key,
    required this.child,
    required this.expand,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return expand ? Expanded(flex: flex, child: child) : child;
  }
}
