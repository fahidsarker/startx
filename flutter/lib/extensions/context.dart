import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/theme_provider.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

extension CtxExt on BuildContext {
  ThemeProvider get tp => watch<ThemeProvider>();
  void showSnackBar(String message, {bool isError = false}) {
    DelightToastBar(
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      builder: (context) => SizedBox(
        width: 20,
        child: ToastCard(
          color: context.c.primary,
          leading: Icon(
            // FontAwesomeIcons.solidBell,
            Icons.notifications,
            size: 28,
            color: context.c.onPrimary,
          ),
          title: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: context.c.onPrimary,
            ),
          ),
        ),
      ),
    ).show(this);
  }

  bool get isWide => MediaQuery.of(this).size.width > 850;
  bool get isUltraWide => MediaQuery.of(this).size.width > 1250;

  T? ifRoute<T>(String route, T widget) {
    if (!route.startsWith('/')) {
      route = '/$route';
    }
    return GoRouterState.of(this).matchedLocation == route ? widget : null;
  }

  GoRouterState get router => GoRouterState.of(this);
  AppColors get c => tp.colors;

  double get defPadding => isWide ? 16.0 : 8.0;
}
