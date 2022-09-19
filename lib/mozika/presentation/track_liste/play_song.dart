import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:mozika/mozika/presentation/common/widget/size.dart';

import 'package:rxdart/rxdart.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../../../core/controller.dart';
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
  const TrackListe(
      {Key? key,
      required this.songIdInSongList,
      required this.songList,
      required this.data,
      required this.playOrPause,
      required this.next,
      required this.prev,
      required this.enBoucle,
      required this.aleatoire})
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
  double toPercentage(Duration actuel, Duration total) {
    double pourcent = 0.0;
    pourcent = (actuel.inMilliseconds * 100) / total.inMilliseconds;
    return pourcent;
  }

//https://www.tanaplanete.mg/wp-content/uploads/2021/02/SHYN-carr%C3%A9.jpg
  Duration toDuration(double actuel, Duration total) {
    Duration duration = Duration(milliseconds: actuel.toInt());

    duration = Duration(milliseconds: (actuel * total.inMilliseconds) ~/ 100);

    return duration;
  }

//changer la couleur selon l'image

  //duration state stream
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          _audioPlayer.positionStream,
          _audioPlayer.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));

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
                                child: StreamBuilder<DurationState>(
                                  stream: _durationStateStream,
                                  builder: (context, snapshot) {
                                    final durationState = snapshot.data;
                                    final progress = durationState?.position ??
                                        Duration.zero;
                                    final total =
                                        durationState?.total ?? Duration.zero;

                                    return SleekCircularSlider(
                                      initialValue:
                                          toPercentage(progress, total).isNaN
                                              ? 0
                                              : toPercentage(progress, total),
                                      min: 0,
                                      max: 100,
                                      onChange: (duration) {
                                        _audioPlayer
                                            .seek(toDuration(duration, total));
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
                                                color: Colors.white
                                                    .withOpacity(.3),
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$value',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: '',
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal),
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
                                                const Color.fromARGB(
                                                    255, 207, 206, 206),
                                            /*progressBar prog restant sur la bar de progression*/
                                            dotColor: Colors.white,
                                            /*dot(anglais)=point ,c'est le point qui indique la progression*/
                                          )),
                                    );
                                  },
                                ),
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
                                    child: StreamBuilder<bool>(
                                      stream: _audioPlayer.playingStream,
                                      builder: (context, snapshot) {
                                        bool? playingState = snapshot.data;
                                        if (playingState != null &&
                                            playingState) {
                                          return const Icon(
                                            FluentSystemIcons
                                                .ic_fluent_play_filled,
                                            size: 35,
                                            color: Colors.black,
                                          );
                                        }
                                        return const Icon(
                                          FluentSystemIcons
                                              .ic_fluent_pause_filled,
                                          size: 35,
                                          color: Colors.black,
                                        );
                                      },
                                    ),
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
/**
 * FutureBuilder<Uint8List?>(
      future: OnAudioQuery().queryArtwork(
        id,
        type,
        format: format ?? ArtworkFormat.JPEG,
        size: size ?? 200,
        quality: quality ?? 100,
      ),
      builder: (context, item) {
        if (item.data != null && item.data!.isNotEmpty) {
          return ClipRRect(
            borderRadius: artworkBorder ?? BorderRadius.circular(50),
            clipBehavior: artworkClipBehavior ?? Clip.antiAlias,
            child: Image.memory(
              item.data!,
              gaplessPlayback: keepOldArtwork ?? false,
              repeat: artworkRepeat ?? ImageRepeat.noRepeat,
              scale: artworkScale ?? 1.0,
              width: artworkWidth ?? 50,
              height: artworkHeight ?? 50,
              fit: artworkFit ?? BoxFit.cover,
              color: artworkColor,
              colorBlendMode: artworkBlendMode,
              filterQuality: artworkQuality ?? FilterQuality.low,
              frameBuilder: frameBuilder,
              errorBuilder: errorBuilder ??
                  (context, exception, stackTrace) {
                    return nullArtworkWidget ??
                        const Icon(
                          Icons.image_not_supported,
                          size: 50,
                        );
                  },
            ),
          );
        }
        return nullArtworkWidget ??
            const Icon(
              Icons.image_not_supported,
              size: 50,
            );
      },
    )



    
 */