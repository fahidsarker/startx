import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/screens/auth/login-screen.dart';
import 'package:flutter_app/screens/auth/registration_screen.dart';
import 'package:flutter_app/screens/home/dashboard_screen.dart';
import 'package:flutter_app/screens/home/echo_demo_screen.dart';
import 'package:flutter_app/screens/home/home_screen.dart';
import 'package:flutter_app/screens/home/profiles_screen.dart';
import 'package:flutter_app/screens/init/init-redirect.dart';
import 'package:flutter_app/screens/welcome.dart';

final globalRouteHistory = <String>[];

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class _RouterChangeNotifier extends ChangeNotifier {
  final Ref ref;

  _RouterChangeNotifier(this.ref) {
    ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = _RouterChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final authRes = ref.read(authProvider);
      if (authRes == null) {
        if (state.routeIn('/profile', '/dashboard', '/echo')) {
          return state.redirTo('/login');
        }
      } else if (state.routeIn('/login', '/registration', '/welcome')) {
        return state.redirTo('/dashboard');
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => InitialRedirectScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => WelcomeScreen()),
      GoRoute(path: '/registration', builder: (_, __) => RegistrationScreen()),
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),

      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/profile', builder: (_, __) => ProfileScreen()),
          GoRoute(path: '/dashboard', builder: (_, __) => DashboardScreen()),
          GoRoute(path: '/echo', builder: (_, __) => const EchoDemoScreen()),
        ],
      ),
    ],
  );
});

extension on GoRouterState {
  bool routeIn(
    String p1, [
    String? p2,
    String? p3,
    String? p4,
    String? p5,
    String? p6,
  ]) {
    final paths = [
      p1,
      if (p2 != null) p2,
      if (p3 != null) p3,
      if (p4 != null) p4,
      if (p5 != null) p5,
      if (p6 != null) p6,
    ];
    for (final path in paths) {
      if (matchedLocation.startsWith(path)) {
        return true;
      }
    }
    return false;
  }

  String? redirTo(String path) {
    if (routeIn(path)) {
      return null;
    }
    return path;
  }
}
