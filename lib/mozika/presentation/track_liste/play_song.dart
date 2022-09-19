import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:mozika/mozika/presentation/common/widget/size.dart';

import '../../data/data_source/local/settings.dart';

class TrackListe extends StatefulWidget {
  final int songIdInSongList;
  final List<SongModel> songList;
  final Uint8List data;
  final VoidCallback playOrPause;
  final VoidCallback next;
  final VoidCallback prev;
  final VoidCallback enBoucle;
  final VoidCallback aleatoire;
  final Widget streamSeek;
  final Widget playingState;
  final bool isPlaying;
  const TrackListe(
      {Key? key,
      required this.songIdInSongList,
      required this.songList,
      required this.data,
      required this.playOrPause,
      required this.next,
      required this.prev,
      required this.enBoucle,
      required this.aleatoire,
      required this.streamSeek,
      required this.isPlaying,
      required this.playingState})
      : super(key: key);

  @override
  State<TrackListe> createState() => _TrackListeState();
}

class _TrackListeState extends State<TrackListe> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final CustomSize _size = CustomSize();
  final Settings _settings = Settings();

//----------------------------------------------------------------
  String currentSongTitle = '';
  String currentSongArtist = '';
  List<SongModel> songsToPlay = [];
  int indexInPlaylist = 0;
  bool isPlaying = false;
  double progressToDouble = 0;
  Color couleurDominant = Colors.red;
  Color white = Colors.grey;
  Color dark = Colors.black;
//----------------------------------------------------------------

  //duration state stream

  @override
  void initState() {
    _settings.requestStoragePermission();
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
    if (widget.data != null && widget.data.isNotEmpty) {
      // Color couleurDominant = snapshot.data!.dominantColor!.color;

      return Scaffold(
        backgroundColor: dark,
        body: SizedBox(
          height: _size.height(context),
          width: _size.width(context),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: _size.height(context),
                  width: _size.width(context),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.memory(
                          widget.data,
                        ).image),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      color: couleurDominant.withOpacity(0.5),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: _size.height(context) * .7,
                        width: _size.width(context),
                        child: Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height: _size.height(context) * .62,
                                width: _size.width(context) * .72,
                                decoration: BoxDecoration(
                                    color: dark,
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: Image.memory(
                                          widget.data,
                                        ).image),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(
                                            _size.width(context) - 100 / 2),
                                        bottomRight: Radius.circular(
                                            _size.width(context) - 100 / 2))),
                              ),
                            ),
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(pi),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                width: _size.width(context),
                                child: widget.streamSeek,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _size.width(context),
                      height: 40,
                      child: Center(
                        child: Text(
                          widget.songList[widget.songIdInSongList].artist
                              .toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),

                    //music title
                    SizedBox(
                      width: _size.width(context),
                      height: 30,
                      child: Center(
                        child: Text(
                          widget.songList[widget.songIdInSongList].title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          width: _size.width(context),
                          height: 45,
                          margin: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white.withOpacity(0.07)),
                        ),
                        Container(
                          width: _size.width(context),
                          height: 90,
                          margin: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: IconButton(
                                    onPressed: widget.aleatoire,
                                    icon: const Icon(
                                      FluentSystemIcons
                                          .ic_fluent_arrow_sort_filled,
                                      color: Colors.white,
                                    )),
                              ),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: IconButton(
                                    onPressed: widget.prev,
                                    icon: const Icon(
                                      FluentSystemIcons
                                          .ic_fluent_previous_filled,
                                      size: 30,
                                      color: Colors.white,
                                    )),
                              ),
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: MaterialButton(
                                  onPressed: widget.playOrPause,
                                  padding: EdgeInsets.zero,
                                  color: Colors.white,
                                  shape: const CircleBorder(),
                                  child: Center(
                                    child: widget.playingState,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: IconButton(
                                  onPressed: widget.next,
                                  icon: const Icon(
                                    FluentSystemIcons.ic_fluent_next_filled,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: IconButton(
                                    onPressed: widget.enBoucle,
                                    icon: const Icon(
                                      FluentSystemIcons
                                          .ic_fluent_arrow_repeat_all_filled,
                                      color: Colors.white,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const Scaffold(
        backgroundColor: Colors.amber,
      );
    }
  }
}

class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}
