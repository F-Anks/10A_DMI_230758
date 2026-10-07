/// Secciones del feed principal, en el orden en que aparecen en la barra.
enum FeedSection {
  forYou('For you'),
  nearYou('Near you'),
  discover('Discover');

  const FeedSection(this.label);

  /// Texto que se muestra en la barra superior.
  final String label;
}
