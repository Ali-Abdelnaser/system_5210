import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playAsset(String path) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(path));
    } catch (e) {
      // Ignore errors in sound play
    }
  }

  // Common sounds
  static Future<void> playCorrect() =>
      playAsset('audio/games/game1/success.mp3');
  static Future<void> playWrong() => playAsset('audio/games/game1/fail.mp3');
  static Future<void> playPop() => playAsset('audio/games/game1/pop.mp3');
}
