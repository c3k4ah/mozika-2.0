import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mozika/core/controller.dart';
import 'package:mozika/mozika/data/data_source/local/settings.dart';
import 'package:mozika/mozika/presentation/common/widget/size.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../common/widget/song_list_widget.dart';

class SongListe extends StatefulWidget {
  const SongListe({super.key});

  @override
  State<SongListe> createState() => _SongListeState();
}

class _SongListeState extends State<SongListe> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final CustomSize _size = CustomSize();
  final Settings _settings = Settings();
  final AudioController _audioController = AudioController();

//-------------------------------------------------------------------------

  List<SongModel> songs = [];
  String currentSongTitle = '';
  String currentSongArtist = '';
  int currentIndex = 0;
  int indexInPlaylist = 0;
  bool isPlaying = false;
  double progressToDouble = 0;

//--------------------------------------------------------------------------

  //update playing song details
  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTitle = songs[index].title;
        currentIndex = index;
      }
    });
  }

//--------------------------------------------------------------------------

  @override
  void initState() {
    _settings.requestStoragePermission();

    //update the current playing song index listener
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }
    });
    super.initState();
  }

  //dispose the player when done
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size.width(context),
      height: _size.height(context),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              //color: Colors.white,
              width: _size.width(context),
              height: _size.height(context),
              child: FutureBuilder<List<SongModel>>(
                future: _audioQuery.querySongs(sortType: SongSortType.TITLE),
                builder: (context, item) {
                  if (item.hasError) {
                    if (item.error is PlatformException) {
                      var error = item.error as PlatformException;

                      return Text(error.message!);
                    } else {
                      return Text('${item.error}');
                    }
                  }

                  // Waiting content.
                  if (item.data == null) {
                    return const CircularProgressIndicator();
                  }

                  // 'Library' is empty.
                  if (item.data!.isEmpty) return const Text("Nothing found!");

                  // You can use [item.data!] direct or you can create a:
                  // List<SongModel> songs = item.data!;
                  return ListView.builder(
                    itemCount: item.data!.length,
                    itemBuilder: (_, index) {
                      // Normal list.
                      var song = item.data![index];
                      return WidgetOfSongListe(
                        data: item.data!,
                        index: index,
                        title: song.title,
                        duration: song.duration!,
                        songIndex: song.id,
                        isPlay: currentIndex == song.id,
                        onPressed: () async {
                          await _audioPlayer.setAudioSource(
                              _audioController.createPlaylist(item.data!),
                              initialIndex: index);
                          await _audioController.isPlayingState();
                          setState(() {
                            currentIndex = index;
                            currentSongTitle = song.title;
                            currentSongArtist = item.data![index].artist!;
                            indexInPlaylist = index;
                            isPlaying = true;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
