import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'widgets/expenses.dart';

void main() async {
  // Needed because we use plugins (SharedPreferences) before runApp().
  WidgetsFlutterBinding.ensureInitialized();
  // Load the saved theme first so the app starts with the right look.
  final themeController = ThemeController();
  await themeController.load();
  runApp(ExpenseTrackerApp(themeController: themeController));
}

/// Root widget. Rebuilds the MaterialApp whenever the selected theme changes.
/// Photo themes always use dark mode; the others follow the system setting.
class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: themeController,
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          final seedColor = themeController.preset.seedColor;
          final translucent = themeController.preset.hasPhotoBackground;
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(
              seedColor,
              Brightness.light,
              translucentSurfaces: translucent,
            ),
            darkTheme: buildAppTheme(
              seedColor,
              Brightness.dark,
              translucentSurfaces: translucent,
            ),
            themeMode: translucent ? ThemeMode.dark : ThemeMode.system,
            home: const Expenses(),
          );
        },
      ),
    );
  }
}
