import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_widgets_app/config/router/app_router.dart';
import 'package:flutter_widgets_app/config/theme/app_theme.dart';
import 'package:flutter_widgets_app/presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final savedColorIndex = prefs.getInt(kSelectedColorKey) ?? 0;
  final savedIsDarkmode = prefs.getBool(kIsDarkmodeKey) ?? false;

  final initialTheme = AppTheme(
    selectedColor: (savedColorIndex >= 0 && savedColorIndex < colorList.length)
        ? savedColorIndex
        : 0,
    isDarkmode: savedIsDarkmode,
  );

  runApp(
    ProviderScope(
      overrides: [
        themeNotifierProvider.overrideWith(
          (ref) => ThemeNotifier(initialTheme, prefs),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppTheme appTheme = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'Ridgets App',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: appTheme.getTheme(),
    );
  }
}
