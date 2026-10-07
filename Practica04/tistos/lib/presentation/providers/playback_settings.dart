import 'package:flutter/foundation.dart';

/// Preferencias de reproducción compartidas por todos los videos.
/// El silencio es global: si silencias un video, el siguiente también lo está.
class PlaybackSettings extends ChangeNotifier {
  bool _isMuted = false;
  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }
}
