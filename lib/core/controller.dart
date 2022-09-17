import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioController {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
//-----------------------------------------------------------
  playAudio(String path) async {
    await _audioQuery.querySongs();
  }

  isPlayingState() {}

  Future<File> artWork(int id) async {
    var art = await _audioQuery.queryArtwork(id, ArtworkType.ALBUM);
    File file = File.fromRawPath(art!);

    return file;
  }

  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }
}

//duration class
class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}
