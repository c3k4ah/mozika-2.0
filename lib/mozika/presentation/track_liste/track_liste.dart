import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:mozika/mozika/presentation/common/widget/size.dart';

import 'package:rxdart/rxdart.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../../../core/controller.dart';
import '../../data/data_source/local/settings.dart';

class TrackListe extends StatefulWidget {
  const TrackListe({Key? key}) : super(key: key);

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
  int currentIndex = 0;
  int indexInPlaylist = 0;
  bool isPlaying = false;
  double progressToDouble = 0;

  Color white = Colors.grey;
  Color dark = Colors.black;
//----------------------------------------------------------------
  double toPercentage(Duration actuel, Duration total) {
    double pourcent = 0.0;
    pourcent = (actuel.inMilliseconds * 100) / total.inMilliseconds;
    return pourcent;
  }

  Duration toDuration(double actuel, Duration total) {
    Duration duration = Duration(milliseconds: actuel.toInt());

    duration = Duration(milliseconds: (actuel * total.inMilliseconds) ~/ 100);

    return duration;
  }

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
    return Scaffold(
      backgroundColor: dark,
      body: SizedBox(
        height: _size.height(context),
        width: _size.width(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: _size.height(context) * .7,
                  width: _size.width(context),
                  color: dark,
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
                              image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image:
                                      ExactAssetImage('assets/pochette.png')),
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
                              final progress =
                                  durationState?.position ?? Duration.zero;
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
                                innerWidget: (value) => Container(),
                                appearance: CircularSliderAppearance(
                                    angleRange: 180,
                                    /* angleRange dégré de l'angle*/
                                    startAngle: 0,
                                    /*startAngle orientation, là on en forme U */
                                    size: _size.width(context) - 40,
                                    customWidths: CustomSliderWidths(
                                      progressBarWidth: 5,
                                      trackWidth: 5,
                                      handlerSize: 8.0,
                                    ),
                                    customColors: CustomSliderColors(
                                      trackColor: Colors.white,
                                      /*track prog déjà faut sur la bar de progression*/
                                      progressBarColor: Colors.white12,
                                      /*progressBar prog restant sur la bar de progression*/
                                      dotColor: Colors.grey,
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
                child: const Expanded(
                  child: Center(
                    child: Text(
                      '02:31' " / " '03:00',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              //music title
              SizedBox(
                width: _size.width(context),
                height: 20,
                child: const Expanded(
                  child: Center(
                    child: Text(
                      'Music Title',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: _size.width(context),
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.shuffle,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: MaterialButton(
                        onPressed: () {},
                        padding: const EdgeInsets.all(0),
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 50,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.repeat,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
