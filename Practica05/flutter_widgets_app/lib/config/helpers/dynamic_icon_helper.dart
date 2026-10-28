import 'package:flutter/services.dart';

class DynamicIconHelper {
  static const MethodChannel _channel =
      MethodChannel('com.example.flutter_widgets_app/dynamic_icon');

  static Future<bool> setThemeIcon(int index) async {
    try {
      final bool? success =
          await _channel.invokeMethod<bool>('setThemeIcon', {'index': index});
      return success ?? false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
