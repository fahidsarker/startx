import 'package:flutter/material.dart';
import 'package:flutter_app/extensions/context.dart';
import 'package:flutter_app/widgets/toolbar.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(context.defPadding),
        child: Row(
          children: [
            if (context.isWide) ...[Toolbar(), const SizedBox(width: 16)],
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
