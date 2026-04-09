import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  double _musicVolume = 0.6;
  double _sfxVolume = 1.0;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[AudioService] $message');
      if (error != null) debugPrint('Detail: $error');
      if (stackTrace != null) debugPrint('$stackTrace');
    }
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _bgmPlayer.setLoopMode(LoopMode.one);
      await _bgmPlayer.setVolume(_musicVolume);
      await _sfxPlayer.setVolume(_sfxVolume);
      _isInitialized = true;
    } catch (e, st) {
      _log('Init audio gagal', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> preloadBgm([String assetPath = 'assets/audio/bgm.mp3']) async {
    await init();
    try {
      await _bgmPlayer.setAsset(assetPath);
    } catch (e, st) {
      _log('Preload BGM gagal: $assetPath', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> playBgm([String assetPath = 'assets/audio/bgm.mp3']) async {
    await init();
    if (!_musicEnabled) return;

    try {
      if (_bgmPlayer.audioSource == null) {
        await _bgmPlayer.setAsset(assetPath);
      }

      if (!_bgmPlayer.playing) {
        await _bgmPlayer.play();
      }
    } catch (e, st) {
      _log('Play BGM gagal: $assetPath', error: e, stackTrace: st);
    }
  }

  Future<void> changeBgm(String assetPath) async {
    await init();
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.setAsset(assetPath);

      if (_musicEnabled) {
        await _bgmPlayer.play();
      }
    } catch (e, st) {
      _log('Ganti BGM gagal: $assetPath', error: e, stackTrace: st);
    }
  }

  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
    } catch (e, st) {
      _log('Pause BGM gagal', error: e, stackTrace: st);
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (e, st) {
      _log('Stop BGM gagal', error: e, stackTrace: st);
    }
  }

  Future<void> resumeBgm() async {
    if (!_musicEnabled) return;

    try {
      if (!_bgmPlayer.playing) {
        await _bgmPlayer.play();
      }
    } catch (e, st) {
      _log('Resume BGM gagal', error: e, stackTrace: st);
    }
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    if (_musicEnabled) {
      await resumeBgm();
    } else {
      await pauseBgm();
    }
  }

  Future<void> toggleMusic() async {
    await setMusicEnabled(!_musicEnabled);
  }

  Future<void> setSfxEnabled(bool value) async {
    _sfxEnabled = value;
  }

  Future<void> toggleSfx() async {
    _sfxEnabled = !_sfxEnabled;
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0.0, 1.0);
    try {
      await _bgmPlayer.setVolume(_musicVolume);
    } catch (e, st) {
      _log('Set volume music gagal', error: e, stackTrace: st);
    }
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0.0, 1.0);
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e, st) {
      _log('Set volume SFX gagal', error: e, stackTrace: st);
    }
  }

  Future<void> playClick([String assetPath = 'assets/audio/click.mp3']) async {
    if (!_sfxEnabled) return;
    await _playSfx(assetPath);
  }

  Future<void> playCorrect([
    String assetPath = 'assets/audio/correct.mp3',
  ]) async {
    if (!_sfxEnabled) return;
    await _playSfx(assetPath);
  }

  Future<void> playWrong([String assetPath = 'assets/audio/wrong.mp3']) async {
    if (!_sfxEnabled) return;
    await _playSfx(assetPath);
  }

  Future<void> playSfx(String assetPath) async {
    if (!_sfxEnabled) return;
    await _playSfx(assetPath);
  }

  Future<void> _playSfx(String assetPath) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.seek(Duration.zero);
      await _sfxPlayer.play();
    } catch (e, st) {
      _log('Play SFX gagal: $assetPath', error: e, stackTrace: st);
    }
  }

  Future<void> dispose() async {
    try {
      await _bgmPlayer.dispose();
      await _sfxPlayer.dispose();
    } catch (e, st) {
      _log('Dispose audio gagal', error: e, stackTrace: st);
    }
  }
}
