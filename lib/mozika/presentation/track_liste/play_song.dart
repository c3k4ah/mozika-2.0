import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:fluentui_icons/fluentui_icons.dart';

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
  String netImg1 =
      "https://static.qobuz.com/images/covers/ia/ao/c364lt28qaoia_600.jpg";
  String netImg = "https://i.ytimg.com/vi/jP3nNdT1abY/maxresdefault.jpg";

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
  Future<PaletteGenerator> _updatePaletteGenerator() async {
    var paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image.network(netImg).image,
    );
    return paletteGenerator;
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
    return FutureBuilder<PaletteGenerator>(
        future: _updatePaletteGenerator(),
        builder:
            (BuildContext context, AsyncSnapshot<PaletteGenerator> snapshot) {
          if (snapshot.hasData) {
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
                              fit: BoxFit.cover, image: NetworkImage(netImg)),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            color: snapshot.data!.dominantColor!.color
                                .withOpacity(0.6),
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
                                              image: NetworkImage(netImg)),
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                  _size.width(context) -
                                                      100 / 2),
                                              bottomRight: Radius.circular(
                                                  _size.width(context) -
                                                      100 / 2))),
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
                                              durationState?.position ??
                                                  Duration.zero;
                                          final total = durationState?.total ??
                                              Duration.zero;

                                          return SleekCircularSlider(
                                            initialValue: toPercentage(
                                                        progress, total)
                                                    .isNaN
                                                ? 0
                                                : toPercentage(progress, total),
                                            min: 0,
                                            max: 100,
                                            onChange: (duration) {
                                              _audioPlayer.seek(
                                                  toDuration(duration, total));
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
                                                  progressBarWidth: 2.5,
                                                  trackWidth: 2.5,
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
                            child: const Center(
                              child: Text(
                                '02:31' " / " '03:00',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),

                          //music title
                          SizedBox(
                            width: _size.width(context),
                            height: 20,
                            child: const Center(
                              child: Text(
                                'Music Title',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal),
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
                                    FluentSystemIcons
                                        .ic_fluent_arrow_sort_filled,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    FluentSystemIcons.ic_fluent_previous_filled,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: MaterialButton(
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                    color: Colors.white,
                                    shape: const CircleBorder(),
                                    child: const Center(
                                      child: Icon(
                                        FluentSystemIcons.ic_fluent_play_filled,
                                        size: 35,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    FluentSystemIcons.ic_fluent_next_filled,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    FluentSystemIcons
                                        .ic_fluent_arrow_repeat_all_filled,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Scaffold();
          }
        });
  }
}
