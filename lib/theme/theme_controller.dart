import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

/// Holds the currently selected app theme. It is a ChangeNotifier, so widgets
/// listening to it rebuild when [selectTheme] is called. The choice is saved
/// in SharedPreferences and restored on the next launch.
class ThemeController extends ChangeNotifier {
  static const _storageKey = 'selected_theme';

  AppThemeId _themeId = AppThemeId.violet;
  AppThemeId get themeId => _themeId;
  AppThemePreset get preset => presetById(_themeId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_storageKey);
    if (savedName == null) return;
    _themeId = AppThemeId.values.firstWhere(
      (id) => id.name == savedName,
      orElse: () => AppThemeId.violet,
    );
  }

  Future<void> selectTheme(AppThemeId id) async {
    if (id == _themeId) return;
    _themeId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, id.name);
  }
}

/// Makes the [ThemeController] available anywhere below it in the widget tree:
/// `ThemeScope.of(context)`. Widgets that call it rebuild on theme changes.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.notifier!;
  }
}
