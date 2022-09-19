import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mozika/mozika/data/data_source/local/settings.dart';

import 'package:mozika/mozika/presentation/common/widget/size.dart';
import 'package:mozika/mozika/presentation/track_liste/play_song.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../data/data_source/local/data.dart';
import '../common/utils/utils.dart';
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
  final Utils _utils = Utils();
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
        _data.setCurrentIndex = index;
      }
    });
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          _audioPlayer.positionStream,
          _audioPlayer.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));
//--------------------------------------------------------------------------
  Future<Widget> someOtherName(int id) async {
    return QueryArtworkWidget(
      id: id,
      type: ArtworkType.ALBUM,
    );
  }

  Duration toDuration(double actuel, Duration total) {
    Duration duration = Duration(milliseconds: actuel.toInt());

    duration = Duration(milliseconds: (actuel * total.inMilliseconds) ~/ 100);

    return duration;
  }

  double toPercentage(Duration actuel, Duration total) {
    double pourcent = 0.0;
    pourcent = (actuel.inMilliseconds * 100) / total.inMilliseconds;
    return pourcent;
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
                streamSeek: StreamBuilder<DurationState>(
                  stream: _durationStateStream,
                  builder: (context, snapshot) {
                    final durationState = snapshot.data;
                    final progress = durationState?.position ?? Duration.zero;
                    final total = durationState?.total ?? Duration.zero;

                    return SleekCircularSlider(
                      initialValue: toPercentage(progress, total).isNaN
                          ? 0
                          : toPercentage(progress, total),
                      min: 0,
                      max: 100,
                      onChange: (value) {
                        _audioPlayer.seek(toDuration(value, total));
                      },
                      /*onChange valeur durant le changement */
                      onChangeEnd: (value) {},
                      /*onChangeEnd valeur à la fin */
                      onChangeStart: (value) {},
                      /* onChangeStart valeur au début */
                      innerWidget: (value) => Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: SizedBox(
                          child: Center(
                            child: Container(
                              width: 80,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.3),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Center(
                                child: Text(
                                  _utils.intToTimeLeft(
                                      toDuration(value, total).inMilliseconds),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      appearance: CircularSliderAppearance(
                          angleRange: 180,
                          /* angleRange dégré de l'angle*/
                          startAngle: 0,
                          /*startAngle orientation, là on en forme U */
                          size: _size.width(context) - 40,
                          customWidths: CustomSliderWidths(
                            progressBarWidth: 1.5,
                            trackWidth: 1.5,
                            handlerSize: 8.0,
                          ),
                          customColors: CustomSliderColors(
                            trackColor: Colors.white,
                            /*track prog déjà faut sur la bar de progression*/
                            progressBarColor:
                                const Color.fromARGB(255, 207, 206, 206),
                            /*progressBar prog restant sur la bar de progression*/
                            dotColor: Colors.white,
                            /*dot(anglais)=point ,c'est le point qui indique la progression*/
                          )),
                    );
                  },
                ),
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
