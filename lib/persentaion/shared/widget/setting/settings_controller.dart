import 'package:flutter/foundation.dart';
import 'package:smaphore_quiz/core/audio/audio_service.dart';

class SettingsController extends ChangeNotifier {
  bool _soundOn = true;
  bool _bgmOn = true;
  bool _vibrationOn = true;

  bool get soundOn => _soundOn;
  bool get bgmOn => _bgmOn;
  bool get vibrationOn => _vibrationOn;

  Future<void> toggleSound() async {
    _soundOn = !_soundOn;
    await AudioService.instance.setSfxEnabled(_soundOn);
    notifyListeners();
  }

  Future<void> toggleBgm() async {
    _bgmOn = !_bgmOn;
    await AudioService.instance.setMusicEnabled(_bgmOn);
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationOn = !_vibrationOn;
    notifyListeners();
  }
}