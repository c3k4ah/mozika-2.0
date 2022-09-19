import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mozika/mozika/data/data_source/local/settings.dart';

import 'package:mozika/mozika/presentation/common/widget/size.dart';
import 'package:mozika/mozika/presentation/track_liste/play_song.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../data/data_source/local/data.dart';
import '../common/widget/appbar.dart';
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
  final TemporaryData _data = TemporaryData();
//-------------------------------------------------------------------------

  List<SongModel> songs = [];
  String currentSongTitle = '';
  String currentSongArtist = '';
  int currentIndex = 0;

  int indexInPlaylist = 0;
  bool isPlaying = false;
  bool isOnScreen = false;
  double progressToDouble = 0;

//--------------------------------------------------------------------------
  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  //update playing song details
  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (_data.getSongs.isNotEmpty) {
        currentSongTitle = _data.getSongs[index].title;
        currentIndex = index;
      }
    });
  }

//--------------------------------------------------------------------------
  Future<Widget> someOtherName(int id) async {
    return QueryArtworkWidget(
      id: id,
      type: ArtworkType.ALBUM,
    );
  }

  @override
  void initState() {
    _settings.requestStoragePermission();
    songs = _data.getSongs;
    currentIndex = _data.getCurrentIndex;
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
    if (isOnScreen) {
      return FutureBuilder<Uint8List?>(
          future: OnAudioQuery().queryArtwork(
            _data.getSongs[_data.getCurrentIndex].id,
            ArtworkType.AUDIO,
          ),
          builder: (context, item) {
            if (item.data != null && item.data!.isNotEmpty) {
              return TrackListe(
                data: item.data!,
                songIdInSongList: _data.getCurrentIndex,
                songList: _data.getSongs,
                next: () {
                  if (_audioPlayer.hasNext) {
                    _audioPlayer.seekToNext();
                  }
                },
                prev: () {
                  if (_audioPlayer.hasPrevious) {
                    _audioPlayer.seekToPrevious();
                  }
                },
                playOrPause: () {
                  if (_audioPlayer.playing) {
                    _audioPlayer.pause();
                  } else {
                    if (_audioPlayer.currentIndex != null) {
                      _audioPlayer.play();
                    }
                  }
                },
                aleatoire: () {
                  if (!_audioPlayer.shuffleModeEnabled) {
                    _audioPlayer.setShuffleModeEnabled(true);
                  } else {
                    _audioPlayer.setShuffleModeEnabled(false);
                  }
                },
                enBoucle: () {
                  _audioPlayer.setLoopMode(LoopMode.one);
                },
              );
            }
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.redAccent,
                ),
              ),
            );
          });
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body: SizedBox(
          width: _size.width(context),
          height: _size.height(context),
          child: SingleChildScrollView(
            child: Container(
              color: const Color.fromARGB(255, 26, 25, 25),
              width: _size.width(context),
              height: _size.height(context),
              child: FutureBuilder<List<SongModel>>(
                future: _audioQuery.querySongs(
                    orderType: OrderType.ASC_OR_SMALLER,
                    sortType: SongSortType.ALBUM),
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
                  //add songs to the song list
                  // _data.getSongs.clear();
                  _data.setSongs = item.data!;

                  return ListView.builder(
                    itemCount: item.data!.length,
                    itemBuilder: (_, index) {
                      // Normal list.
                      var song = item.data![index];
                      return WidgetOfSongListe(
                        data: item.data!,
                        index: index,
                        album: song.album!,
                        artist: song.artist!,
                        title: song.title,
                        duration: song.duration!,
                        songIndex: song.id,
                        isPlay: _data.getCurrentIndex == index &&
                            _audioPlayer.playing,
                        onDoubleTape: () {
                          setState(() {
                            isOnScreen = true;
                          });
                        },
                        onPressed: () async {
                          _data.setCurrentIndex = index;

                          await _audioPlayer.setAudioSource(
                              createPlaylist(item.data!),
                              initialIndex: index);
                          if (_audioPlayer.playing) {
                            _audioPlayer.pause();
                          } else {
                            if (_audioPlayer.currentIndex != null) {
                              _audioPlayer.play();
                            }
                          }
                          setState(() {
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
          ),
        ),
        bottomNavigationBar: const BottomBar(),
      );
    }
  }
}
