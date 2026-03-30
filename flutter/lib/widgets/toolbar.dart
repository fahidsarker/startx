import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_app/extensions/color.dart';
import 'package:flutter_app/extensions/context.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/screens/error_screen.dart';
import 'package:flutter_app/utils/utils.dart';

Icon themeModeIcon(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return Icon(Icons.brightness_auto);
    case ThemeMode.light:
      return Icon(Icons.wb_sunny);
    case ThemeMode.dark:
      return Icon(Icons.nights_stay);
  }
}

class Toolbar extends HookConsumerWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);
    final currentPath = GoRouterState.of(context).fullPath ?? 'xx';
    final themeProvider = context.tp;

    final auth = ref.watch(authProvider);
    if (auth == null) {
      return const ErrorScreen();
    }

    final toolbarItems = [
      (
        title: 'Dashboard',
        icon: Icon(Icons.dashboard),
        href: '/dashboard',
        onClick: null,
      ),
      (
        title: 'Echo',
        icon: Icon(Icons.compare_arrows),
        href: '/echo',
        onClick: null,
      ),

      (title: '_', icon: Icon(Icons.more_horiz), href: null, onClick: null),

      (
        title: capitalize(themeProvider.themeMode.name),
        icon: themeModeIcon(themeProvider.themeMode),
        href: null,
        onClick: () => themeProvider.toggleThemeMode(),
      ),
      (
        title: 'Settings',
        icon: Icon(Icons.settings),
        href: null,
        onClick: null,
      ),
      (
        title: auth.user.name,
        icon: auth.user.profilePhotoUrl == null
            ? Icon(Icons.person)
            : CircleAvatar(
                backgroundImage: NetworkImage(auth.user.profilePhotoUrl!),
                radius: 12,
              ),
        href: '/profile',
        onClick: null,
      ),
      (
        title: expanded.value ? 'Collapse' : 'Expand',
        icon: expanded.value
            ? Icon(FontAwesomeIcons.angleLeft)
            : Icon(FontAwesomeIcons.angleRight),
        href: null,
        onClick: () {
          expanded.value = !expanded.value;
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var item in toolbarItems)
          if (item.title == '_')
            const Spacer()
          else if (expanded.value)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.c.textSecondary,
                backgroundColor: currentPath.contains(item.href ?? 'zz')
                    ? context.c.textSecondary.wOpacity(0.2)
                    : Colors.transparent,
              ),
              onPressed: () {
                if (item.onClick != null) {
                  item.onClick!();
                }
                if (item.href != null) {
                  context.go(item.href!);
                }
              },
              child: SizedBox(
                width: context.isUltraWide ? 200 : 120,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    item.icon,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: currentPath.contains(item.href ?? 'zz')
                    ? context.c.textSecondary.wOpacity(0.2)
                    : Colors.transparent,
                foregroundColor: context.c.textSecondary,
              ),
              icon: item.icon,
              tooltip: item.title,
              onPressed: () {
                if (item.onClick != null) {
                  item.onClick!();
                }
                if (item.href != null) {
                  context.go(item.href!);
                }
              },
            ),
      ],
    );
  }
}
