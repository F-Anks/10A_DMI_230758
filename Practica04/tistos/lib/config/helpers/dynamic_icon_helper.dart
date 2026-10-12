import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tistos/config/helpers/logo_helper.dart';

/// Gestiona la actualización dinámica del icono de la aplicación en el launcher de Android
/// según la temporada activa (Halloween, Navidad, San Valentín, Aniversario o Normal).
class DynamicIconHelper {
  static const MethodChannel _channel = MethodChannel('com.example.tistos/dynamic_icon');

  /// Sincroniza el icono del launcher de Android con la temporada actual de la app.
  static Future<bool> syncWithCurrentSeason([DateTime? date]) async {
    // Solo aplica a plataformas Android con soporte nativo
    if (kIsWeb) return false;

    try {
      final theme = LogoHelper.getCurrentSeasonTheme(date);
      final seasonName = theme.season.name; // anniversary, halloween, christmas, valentine, normal

      final result = await _channel.invokeMethod<bool>('setSeasonalIcon', {
        'season': seasonName,
      });

      debugPrint('DynamicIconHelper: Icono del launcher sincronizado a temporada "$seasonName" (Éxito: $result)');
      return result ?? false;
    } catch (e) {
      debugPrint('DynamicIconHelper: No se pudo cambiar el icono dinámico: $e');
      return false;
    }
  }
}
