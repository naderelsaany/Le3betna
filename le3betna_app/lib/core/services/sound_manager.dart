import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  bool isMuted = false;

  void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
  }

  Future<void> playSfx(String file) async {
    if (isMuted) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/$file'));
    } catch (e) {
      // Ignore if sound fails to play
    }
  }

  Future<void> playBgm(String file) async {
    if (isMuted) return;
    try {
      _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('sounds/$file'));
    } catch (e) {
      // Ignore
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }
}
