import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Catálogo activo en la aplicación: películas o series.
enum CatalogType {
  movies,
  series,
}

final catalogTypeProvider = StateProvider<CatalogType>(
  (ref) => CatalogType.movies,
);
