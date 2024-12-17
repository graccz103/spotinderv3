import 'package:audioplayers/audioplayers.dart';

class PreviewPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? currentPreviewUrl;

  Future<void> playPreview(String url, Function(String?) updateState) async {
    if (currentPreviewUrl == url) {
      await _audioPlayer.stop();
      updateState(null);
    } else {
      await _audioPlayer.play(UrlSource(url));
      updateState(url);
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
