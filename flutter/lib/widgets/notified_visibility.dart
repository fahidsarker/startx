import 'package:flutter/material.dart';

class NotifiedVisibility extends StatelessWidget {
  final Widget child;
  final ValueNotifier<bool> visibleNotifier;
  final bool reverse;
  const NotifiedVisibility({
    super.key,
    required this.child,
    required this.visibleNotifier,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visibleNotifier,
      builder: (context, isVisible, _) {
        final visible = reverse ? !isVisible : isVisible;
        return visible ? child : const SizedBox.shrink();
      },
    );
  }
}
