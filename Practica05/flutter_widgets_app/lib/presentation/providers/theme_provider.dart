import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_widgets_app/config/helpers/dynamic_icon_helper.dart';
import 'package:flutter_widgets_app/config/theme/app_theme.dart';

const String kSelectedColorKey = 'selected_color_theme';
const String kIsDarkmodeKey = 'is_dark_mode';

// Listado de colores inmutable
final colorListProvider = Provider((ref) => colorList);

// Un simple boolean
final isDarkmodeProvider = StateProvider((ref) => false);

// Un simple int
final selectedColorProvider = StateProvider((ref) => 0);

// Un objeto de tipo AppTheme (custom)
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppTheme>(
  (ref) => ThemeNotifier(),
);

// Controller o Notifier
class ThemeNotifier extends StateNotifier<AppTheme> {
  SharedPreferences? _prefs;

  ThemeNotifier([AppTheme? initialTheme, SharedPreferences? prefs])
      : _prefs = prefs,
        super(initialTheme ?? AppTheme()) {
    if (_prefs == null) {
      _loadPreferences();
    }
  }

  Future<void> _loadPreferences() async {
    _prefs ??= await SharedPreferences.getInstance();
    final savedColor = _prefs?.getInt(kSelectedColorKey);
    final savedDarkmode = _prefs?.getBool(kIsDarkmodeKey);

    if (savedColor != null || savedDarkmode != null) {
      final safeColor = (savedColor != null &&
              savedColor >= 0 &&
              savedColor < colorList.length)
          ? savedColor
          : state.selectedColor;
      final safeDark = savedDarkmode ?? state.isDarkmode;

      state = state.copyWith(
        selectedColor: safeColor,
        isDarkmode: safeDark,
      );
    }
  }

  void toggleDarkmode() {
    final newDarkmode = !state.isDarkmode;
    state = state.copyWith(isDarkmode: newDarkmode);
    _prefs?.setBool(kIsDarkmodeKey, newDarkmode);
  }

  void changeColorIndex(int colorIndex) {
    if (colorIndex < 0 || colorIndex >= colorList.length) return;
    state = state.copyWith(selectedColor: colorIndex);
    _prefs?.setInt(kSelectedColorKey, colorIndex);
    DynamicIconHelper.setThemeIcon(colorIndex);
  }
}
