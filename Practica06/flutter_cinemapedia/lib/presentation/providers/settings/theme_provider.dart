import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/presentation/providers/settings/shared_preferences_provider.dart';

const _themeDarkKey = 'app_theme_is_dark';
const _themeColorKey = 'app_theme_color_index';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs)
      : super(
          AppTheme(
            isDarkmode: _prefs.getBool(_themeDarkKey) ?? true,
            selectedColor: _prefs.getInt(_themeColorKey) ?? 0,
          ),
        );

  Future<void> setDarkMode(bool isDark) async {
    state = state.copyWith(isDarkmode: isDark);
    await _prefs.setBool(_themeDarkKey, isDark);
  }

  Future<void> selectColorIndex(int index) async {
    state = state.copyWith(selectedColor: index);
    await _prefs.setInt(_themeColorKey, index);
  }
}
