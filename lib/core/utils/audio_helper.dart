import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioHapticHelper {
  /// Memainkan feedback getar sesuai preferensi
  static Future<void> triggerVibration() async {
    try {
      if (!kIsWeb) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.vibrate();
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  /// Memainkan bunyi alarm / alert sistem
  static Future<void> triggerSystemSound() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  /// Menjalankan sinyal peringatan gabungan (bunyi + getar sesuai setting)
  static Future<void> triggerAlert({
    required bool playSound,
    required bool vibrate,
  }) async {
    if (vibrate) {
      await triggerVibration();
    }
    if (playSound) {
      await triggerSystemSound();
    }
  }
}
