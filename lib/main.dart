import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/screens/social_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final isLoggedIn = ref.watch(sessionProvider);

    return MaterialApp(
      title: 'Social Tree',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // Custom builder to wrap the entire subtree in an AnimatedTheme for customized duration transitions
      builder: (context, child) {
        final currentThemeMode = ref.watch(themeControllerProvider);
        final systemBrightness = MediaQuery.of(context).platformBrightness;

        final isDark =
            currentThemeMode == ThemeMode.dark ||
            (currentThemeMode == ThemeMode.system &&
                systemBrightness == Brightness.dark);

        return AnimatedTheme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: isLoggedIn ? const SocialHomeScreen() : const AuthScreen(),
    );
  }
}
