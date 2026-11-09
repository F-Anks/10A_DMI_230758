import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cinemapedia/config/helpers/logo_helper.dart';

/// Sincroniza el icono del launcher de Android con la temporada activa según la fecha del dispositivo.
class DynamicIconHelper {
  static const MethodChannel _channel = MethodChannel(
    'com.example.flutter_cinemapedia/dynamic_icon',
  );

  static Future<bool> syncWithCurrentSeason([DateTime? date]) async {
    if (kIsWeb) return false;

    try {
      final theme = LogoHelper.getCurrentSeasonTheme(date);
      final seasonName = theme.season.name;

      final result = await _channel.invokeMethod<bool>('setSeasonalIcon', {
        'season': seasonName,
      });

      return result ?? false;
    } catch (e) {
      debugPrint('DynamicIconHelper: No se pudo cambiar el icono dinámico: $e');
      return false;
    }
  }
}

