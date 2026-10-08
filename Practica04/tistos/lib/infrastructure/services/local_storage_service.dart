import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tistos/domain/entities/video_post.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  static void saveVideoData(VideoPost video) {
    _prefs.setString('video_${video.id}', jsonEncode(video.toJson()));
  }

  static Map<String, dynamic>? getVideoData(String id) {
    final str = _prefs.getString('video_$id');
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }

  static void toggleFavorite(String id, bool isLiked) {
    final favs = getFavorites();
    if (isLiked && !favs.contains(id)) {
      favs.add(id);
    } else if (!isLiked && favs.contains(id)) {
      favs.remove(id);
    }
    _prefs.setStringList('favorites', favs);
  }

  static List<String> getFavorites() {
    return _prefs.getStringList('favorites') ?? [];
  }

  static bool get hasAcceptedPrivacy => _prefs.getBool('accepted_privacy') ?? false;
  
  static Future<void> acceptPrivacy() async {
    await _prefs.setBool('accepted_privacy', true);
  }
}
