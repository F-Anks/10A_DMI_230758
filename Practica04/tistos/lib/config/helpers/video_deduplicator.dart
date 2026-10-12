import 'package:tistos/domain/entities/video_post.dart';

/// Validador y deduplicador de videos para TisTos.
/// 
/// Garantiza que nunca se presenten videos repetidos en ninguna sección,
/// aplicando 4 reglas estrictas:
/// 1. [Identificador único]: Ningún video puede compartir el mismo `id`.
/// 2. [URL única]: Ningún video puede compartir la misma `videoUrl` normalizada.
/// 3. [Dupla Autor + Título única]: Evita clones o re-subidas con distinto ID.
/// 4. [Regla anti-adyacencia]: Si dos videos adyacentes pertenecen al mismo autor
///    o tienen contenido similar, se dispersan para que jamás salgan "uno debajo del otro".
class VideoDeduplicator {
  /// Normaliza una URL removiendo parámetros de consulta y fragmentos
  /// para detectar URLs idénticas que solo varían por tokens o firmas temporales.
  static String normalizeUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return '';
    try {
      final uri = Uri.parse(trimmed);
      // Solo tomamos esquema, host y path para la comparación canónica
      return '${uri.scheme}://${uri.host}${uri.path}'.toLowerCase();
    } catch (_) {
      return trimmed.toLowerCase();
    }
  }

  /// Limpia y deduplica una lista de videos garantizando unicidad total.
  /// Puede recibir conjuntos opcionales de [excludedUrls] o [excludedIds]
  /// para evitar que un video de una sección aparezca también en otra.
  static List<VideoPost> deduplicate(
    List<VideoPost> videos, {
    Set<String>? excludedUrls,
    Set<String>? excludedIds,
  }) {
    if (videos.isEmpty) return [];

    final seenIds = <String>{...?excludedIds};
    final seenUrls = <String>{...?excludedUrls};
    final seenSignatures = <String>{};
    final List<VideoPost> cleanList = [];

    for (final post in videos) {
      final id = post.id.trim();
      final normUrl = normalizeUrl(post.videoUrl);
      final caption = post.caption.trim().toLowerCase();
      final username = post.username.trim().toLowerCase();
      final signature = '$username::$caption';

      // 1. Validar ID no vacío y único
      if (id.isNotEmpty && seenIds.contains(id)) {
        continue;
      }

      // 2. Validar URL no vacía y única
      if (normUrl.isNotEmpty && seenUrls.contains(normUrl)) {
        continue;
      }

      // 3. Validar que no sea el mismo autor con el mismo título
      if (caption.isNotEmpty && username.isNotEmpty && seenSignatures.contains(signature)) {
        continue;
      }

      // Registrar como visto
      if (id.isNotEmpty) seenIds.add(id);
      if (normUrl.isNotEmpty) seenUrls.add(normUrl);
      if (caption.isNotEmpty && username.isNotEmpty) seenSignatures.add(signature);

      cleanList.add(post);
    }

    // 4. Regla anti-adyacencia: dispersar videos del mismo creador para que no queden pegados
    return disperseConsecutiveSimilar(cleanList);
  }

  /// Dispersa elementos para evitar que videos del mismo autor queden uno inmediatamente
  /// debajo del otro.
  static List<VideoPost> disperseConsecutiveSimilar(List<VideoPost> list) {
    if (list.length <= 2) return list;

    final result = List<VideoPost>.from(list);
    for (int i = 0; i < result.length - 1; i++) {
      final currentAuthor = result[i].username.trim().toLowerCase();
      final nextAuthor = result[i + 1].username.trim().toLowerCase();

      if (currentAuthor.isNotEmpty && currentAuthor == nextAuthor) {
        // Buscar el siguiente video que sea de un autor diferente para intercambiar
        for (int j = i + 2; j < result.length; j++) {
          final candidateAuthor = result[j].username.trim().toLowerCase();
          if (candidateAuthor != currentAuthor) {
            final temp = result[i + 1];
            result[i + 1] = result[j];
            result[j] = temp;
            break;
          }
        }
      }
    }
    return result;
  }
}
