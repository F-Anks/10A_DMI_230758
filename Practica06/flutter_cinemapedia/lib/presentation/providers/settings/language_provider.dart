import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/i18n/app_language.dart';
import 'package:cinemapedia/presentation/providers/settings/shared_preferences_provider.dart';

const _languagePrefsKey = 'app_language_api_code';

final languageProvider = StateProvider<AppLanguage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final savedCode = prefs.getString(_languagePrefsKey);
  return AppLanguages.fromApiCode(savedCode);
});

Future<void> changeLanguage(WidgetRef ref, AppLanguage language) async {
  ref.read(languageProvider.notifier).state = language;
  final prefs = ref.read(sharedPreferencesProvider);
  await prefs.setString(_languagePrefsKey, language.apiCode);
}
