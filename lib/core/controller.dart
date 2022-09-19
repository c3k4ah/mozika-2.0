import 'package:on_audio_query/on_audio_query.dart';

class AudioController {
  final OnAudioQuery _audioQuery = OnAudioQuery();
//-----------------------------------------------------------
  playAudio(String path) async {
    await _audioQuery.querySongs();
  }
}

//duration class

