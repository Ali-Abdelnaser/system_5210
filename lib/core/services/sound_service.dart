import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static const String _audioPath = 'audio/games/game1/';

  static Future<void> playCorrect() async {
    await _player.play(AssetSource('${_audioPath}correct.mp3'));
  }

  static Future<void> playWrong() async {
    await _player.play(AssetSource('${_audioPath}wrong.mp3'));
  }

  static Future<void> playClick() async {
    await _player.play(AssetSource('${_audioPath}click.mp3'));
  }

  static Future<void> playWin() async {
    await _player.play(AssetSource('${_audioPath}win.mp3'));
  }
}
