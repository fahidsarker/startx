import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart' as p;
import 'package:flutter_app/router.dart';
import 'package:solid_shared_pref/solid_shared_pref.dart';
import 'providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_app/core/url_strategy_stub.dart'
    if (dart.library.html) 'package:flutter_app/core/url_strategy_web.dart';

void main() async {
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
  initSolidSharedPreferences();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);

    return p.ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: p.Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Ripple Chat',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
