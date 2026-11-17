import 'package:flutter/material.dart';

/// Textos localizados de CinePedia para los 5 idiomas soportados:
/// Español (es), Inglés (en), Alemán (de), Chino (zh) y Árabe (ar).
class AppStrings {
  final String home;
  final String popular;
  final String favorites;
  final String nowPlaying;
  final String upcoming;
  final String upcomingSub;
  final String topRated;
  final String topRatedSub;
  final String seriesOnAir;
  final String airingToday;
  final String airingTodaySub;
  final String searchMovies;
  final String searchSeries;
  final String releaseDate;
  final String ageRating;
  final String videos;
  final String videosError;
  final String recommendations;
  final String recommendationsError;
  final String favoritesEmptyTitle;
  final String favoritesEmptyMovies;
  final String favoritesEmptySeries;
  final String startSearching;
  final String pleaseWait;
  final String loading;
  final List<String> loaderMessagesMovies;
  final List<String> loaderMessagesSeries;
  final String settings;
  final String content;
  final String chooseContent;
  final String movies;
  final String series;
  final String language;
  final String chooseLanguage;
  final String themeSection;
  final String darkMode;
  final String lightMode;
  final List<String> seasonThemeNames;

  const AppStrings({
    required this.home,
    required this.popular,
    required this.favorites,
    required this.nowPlaying,
    required this.upcoming,
    required this.upcomingSub,
    required this.topRated,
    required this.topRatedSub,
    required this.seriesOnAir,
    required this.airingToday,
    required this.airingTodaySub,
    required this.searchMovies,
    required this.searchSeries,
    required this.releaseDate,
    required this.ageRating,
    required this.videos,
    required this.videosError,
    required this.recommendations,
    required this.recommendationsError,
    required this.favoritesEmptyTitle,
    required this.favoritesEmptyMovies,
    required this.favoritesEmptySeries,
    required this.startSearching,
    required this.pleaseWait,
    required this.loading,
    required this.loaderMessagesMovies,
    required this.loaderMessagesSeries,
    required this.settings,
    required this.content,
    required this.chooseContent,
    required this.movies,
    required this.series,
    required this.language,
    required this.chooseLanguage,
    required this.themeSection,
    required this.darkMode,
    required this.lightMode,
    required this.seasonThemeNames,
  });

  static AppStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return _values[code] ?? _es;
  }

  static AppStrings byCode(String code) => _values[code] ?? _es;

  static const _es = AppStrings(
    home: 'Inicio',
    popular: 'Populares',
    favorites: 'Favoritos',
    nowPlaying: 'En cines',
    upcoming: 'Próximamente',
    upcomingSub: 'En este mes',
    topRated: 'Mejor calificadas',
    topRatedSub: 'Desde siempre',
    seriesOnAir: 'En emisión',
    airingToday: 'Se emiten hoy',
    airingTodaySub: 'Episodios nuevos',
    searchMovies: 'Buscar películas',
    searchSeries: 'Buscar series',
    releaseDate: 'Estreno:',
    ageRating: 'Clasificación:',
    videos: 'Videos',
    videosError: 'No se pudieron cargar los videos',
    recommendations: 'Recomendaciones',
    recommendationsError: 'No se pudieron cargar recomendaciones',
    favoritesEmptyTitle: 'Ohhh no!!',
    favoritesEmptyMovies: 'No tienes películas favoritas',
    favoritesEmptySeries: 'No tienes series favoritas',
    startSearching: 'Empieza a buscar',
    pleaseWait: 'Espere por favor',
    loading: 'Cargando...',
    loaderMessagesMovies: [
      'Cargando películas',
      'Comprando palomitas de maíz',
      'Cargando populares',
      'Preparando estrenos',
      'Ya mero...',
      'Esto está tardando más de lo esperado :(',
    ],
    loaderMessagesSeries: [
      'Cargando series',
      'Preparando el maratón',
      'Cargando populares',
      'Buscando episodios nuevos',
      'Ya mero...',
      'Esto está tardando más de lo esperado :(',
    ],
    settings: 'Configuración',
    content: 'Contenido',
    chooseContent: 'Elige qué catálogo explorar',
    movies: 'Películas',
    series: 'Series',
    language: 'Idioma',
    chooseLanguage: 'Idioma de la app y del catálogo',
    themeSection: 'Tema de la interfaz',
    darkMode: 'Oscuro',
    lightMode: 'Claro',
    seasonThemeNames: [
      'Normal',
      'Navidad',
      'Día del Cine',
      'San Valentín',
      'Halloween',
      'Aniversario',
    ],
  );

  static const _en = AppStrings(
    home: 'Home',
    popular: 'Popular',
    favorites: 'Favorites',
    nowPlaying: 'In theaters',
    upcoming: 'Coming soon',
    upcomingSub: 'This month',
    topRated: 'Top rated',
    topRatedSub: 'All time',
    seriesOnAir: 'On the air',
    airingToday: 'Airing today',
    airingTodaySub: 'New episodes',
    searchMovies: 'Search movies',
    searchSeries: 'Search series',
    releaseDate: 'Release:',
    ageRating: 'Age rating:',
    videos: 'Videos',
    videosError: 'Could not load videos',
    recommendations: 'Recommendations',
    recommendationsError: 'Could not load recommendations',
    favoritesEmptyTitle: 'Oh no!!',
    favoritesEmptyMovies: 'You have no favorite movies',
    favoritesEmptySeries: 'You have no favorite series',
    startSearching: 'Start exploring',
    pleaseWait: 'Please wait',
    loading: 'Loading...',
    loaderMessagesMovies: [
      'Loading movies',
      'Grabbing some popcorn',
      'Loading popular titles',
      'Preparing upcoming releases',
      'Almost ready...',
      'Taking a bit longer than expected :(',
    ],
    loaderMessagesSeries: [
      'Loading series',
      'Getting ready to binge',
      'Loading popular shows',
      'Checking new episodes',
      'Almost ready...',
      'Taking a bit longer than expected :(',
    ],
    settings: 'Settings',
    content: 'Content',
    chooseContent: 'Choose catalog to explore',
    movies: 'Movies',
    series: 'Series',
    language: 'Language',
    chooseLanguage: 'App and catalog language',
    themeSection: 'Interface theme',
    darkMode: 'Dark',
    lightMode: 'Light',
    seasonThemeNames: [
      'Default',
      'Christmas',
      'Cinema Day',
      'Valentine',
      'Halloween',
      'Anniversary',
    ],
  );

  static const _de = AppStrings(
    home: 'Start',
    popular: 'Beliebt',
    favorites: 'Favoriten',
    nowPlaying: 'Im Kino',
    upcoming: 'Demnächst',
    upcomingSub: 'In diesem Monat',
    topRated: 'Bestbewertet',
    topRatedSub: 'Aller Zeiten',
    seriesOnAir: 'Aktuell im TV',
    airingToday: 'Heute im TV',
    airingTodaySub: 'Neue Folgen',
    searchMovies: 'Filme suchen',
    searchSeries: 'Serien suchen',
    releaseDate: 'Start:',
    ageRating: 'Altersfreigabe:',
    videos: 'Videos',
    videosError: 'Videos konnten nicht geladen werden',
    recommendations: 'Empfehlungen',
    recommendationsError: 'Empfehlungen konnten nicht geladen werden',
    favoritesEmptyTitle: 'Oh nein!!',
    favoritesEmptyMovies: 'Keine Lieblingsfilme gespeichert',
    favoritesEmptySeries: 'Keine Lieblingsserien gespeichert',
    startSearching: 'Jetzt entdecken',
    pleaseWait: 'Bitte warten',
    loading: 'Wird geladen...',
    loaderMessagesMovies: [
      'Filme werden geladen',
      'Popcorn wird vorbereitet',
      'Beliebte Filme laden',
      'Neuerscheinungen werden geladen',
      'Gleich fertig...',
      'Dauert etwas länger als erwartet :(',
    ],
    loaderMessagesSeries: [
      'Serien werden geladen',
      'Marathon wird vorbereitet',
      'Beliebte Serien laden',
      'Neue Folgen werden gesucht',
      'Gleich fertig...',
      'Dauert etwas länger als erwartet :(',
    ],
    settings: 'Einstellungen',
    content: 'Inhalt',
    chooseContent: 'Katalog auswählen',
    movies: 'Filme',
    series: 'Serien',
    language: 'Sprache',
    chooseLanguage: 'App- und Katalogsprache',
    themeSection: 'App-Design',
    darkMode: 'Dunkel',
    lightMode: 'Hell',
    seasonThemeNames: [
      'Standard',
      'Weihnachten',
      'Kinotag',
      'Valentinstag',
      'Halloween',
      'Jubiläum',
    ],
  );

  static const _zh = AppStrings(
    home: '首页',
    popular: '热门',
    favorites: '收藏',
    nowPlaying: '正在热映',
    upcoming: '即将上映',
    upcomingSub: '本月',
    topRated: '高分佳作',
    topRatedSub: '历史最佳',
    seriesOnAir: '正在播出',
    airingToday: '今日播出',
    airingTodaySub: '最新剧集',
    searchMovies: '搜索电影',
    searchSeries: '搜索剧集',
    releaseDate: '上映日期:',
    ageRating: '年龄分级:',
    videos: '预告片',
    videosError: '无法加载视频',
    recommendations: '相关推荐',
    recommendationsError: '无法加载推荐内容',
    favoritesEmptyTitle: '哎呀!!',
    favoritesEmptyMovies: '暂无收藏的电影',
    favoritesEmptySeries: '暂无收藏的剧集',
    startSearching: '开始探索',
    pleaseWait: '请稍候',
    loading: '加载中...',
    loaderMessagesMovies: [
      '正在加载电影',
      '正在准备爆米花',
      '正在加载热门影片',
      '正在加载即将上映',
      '马上就好...',
      '耗时比预期长了一点 :(',
    ],
    loaderMessagesSeries: [
      '正在加载剧集',
      '准备开启追剧模式',
      '正在加载热门剧集',
      '正在获取最新剧集',
      '马上就好...',
      '耗时比预期长了一点 :(',
    ],
    settings: '设置',
    content: '内容',
    chooseContent: '选择要浏览的目录',
    movies: '电影',
    series: '剧集',
    language: '语言',
    chooseLanguage: '应用与目录语言',
    themeSection: '界面主题',
    darkMode: '深色',
    lightMode: '浅色',
    seasonThemeNames: [
      '默认',
      '圣诞节',
      '电影日',
      '情人节',
      '万圣节',
      '周年庆',
    ],
  );

  static const _ar = AppStrings(
    home: 'الرئيسية',
    popular: 'الشائعة',
    favorites: 'المفضلة',
    nowPlaying: 'في دور العرض',
    upcoming: 'قريبًا',
    upcomingSub: 'هذا الشهر',
    topRated: 'الأعلى تقييمًا',
    topRatedSub: 'على الإطلاق',
    seriesOnAir: 'يُعرض حاليًا',
    airingToday: 'يُعرض اليوم',
    airingTodaySub: 'حلقات جديدة',
    searchMovies: 'ابحث عن أفلام',
    searchSeries: 'ابحث عن مسلسلات',
    releaseDate: 'تاريخ الإصدار:',
    ageRating: 'التصنيف العمري:',
    videos: 'مقاطع الفيديو',
    videosError: 'تعذر تحميل مقاطع الفيديو',
    recommendations: 'توصيات مشابهة',
    recommendationsError: 'تعذر تحميل التوصيات',
    favoritesEmptyTitle: 'يا إلهي!!',
    favoritesEmptyMovies: 'لا توجد أفلام مفضلة لديك',
    favoritesEmptySeries: 'لا توجد مسلسلات مفضلة لديك',
    startSearching: 'ابدأ الاستكشاف',
    pleaseWait: 'يرجى الانتظار',
    loading: 'جارٍ التحميل...',
    loaderMessagesMovies: [
      'جارٍ تحميل الأفلام',
      'تحضير الفشار...',
      'تحميل الأفلام الشائعة',
      'تجهيز العروض القادمة',
      'وشك الانتهاء...',
      'يستغرق وقتًا أطول من المتوقع :(',
    ],
    loaderMessagesSeries: [
      'جارٍ تحميل المسلسلات',
      'الاستعداد للمشاهدة',
      'تحميل المسلسلات الشائعة',
      'البحث عن حلقات جديدة',
      'وشك الانتهاء...',
      'يستغرق وقتًا أطول من المتوقع :(',
    ],
    settings: 'الإعدادات',
    content: 'المحتوى',
    chooseContent: 'اختر الفئة للاستكشاف',
    movies: 'أفلام',
    series: 'مسلسلات',
    language: 'اللغة',
    chooseLanguage: 'لغة التطبيق والبيانات',
    themeSection: 'مظهر التطبيق',
    darkMode: 'داكن',
    lightMode: 'فاتح',
    seasonThemeNames: [
      'عادي',
      'الكريسماس',
      'يوم السينما',
      'عيد الحب',
      'الهالوين',
      'الذكرى السنوية',
    ],
  );

  static const Map<String, AppStrings> _values = {
    'es': _es,
    'en': _en,
    'de': _de,
    'zh': _zh,
    'ar': _ar,
  };
}
