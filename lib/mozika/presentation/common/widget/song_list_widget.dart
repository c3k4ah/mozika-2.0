import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:mozika/mozika/presentation/common/widget/size.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../utils/utils.dart';

class WidgetOfSongListe extends StatefulWidget {
  final List data;
  final int index;
  final bool isPlay;
  final String title;
  final int duration;
  final int songIndex;
  final String album;
  final String artist;
  final VoidCallback onPressed;
  final VoidCallback onDoubleTape;

  const WidgetOfSongListe(
      {super.key,
      required this.data,
      required this.index,
      required this.isPlay,
      required this.title,
      required this.duration,
      required this.songIndex,
      required this.onPressed,
      required this.album,
      required this.artist,
      required this.onDoubleTape});

  @override
  State<WidgetOfSongListe> createState() => _WidgetOfSongListeState();
}

class _WidgetOfSongListeState extends State<WidgetOfSongListe> {
  final CustomSize _size = CustomSize();
  final Utils _utils = Utils();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onDoubleTap: widget.onDoubleTape,
      onTap: widget.onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        height: 80,
        width: _size.width(context),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 32, 32, 32),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.isPlay
                ? IconButton(
                    onPressed: widget.onPressed,
                    icon: const Icon(
                      FluentSystemIcons.ic_fluent_pause_filled,
                      color: Colors.white,
                    ))
                : IconButton(
                    onPressed: widget.onPressed,
                    icon: const Icon(
                      FluentSystemIcons.ic_fluent_play_filled,
                      color: Colors.white,
                    )) /*SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        (widget.index + 1).toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),*/
            ,
            QueryArtworkWidget(
              id: widget.songIndex,
              type: ArtworkType.AUDIO,
              artworkBorder: BorderRadius.circular(15),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: _size.width(context) * .45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    widget.title.toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.normal),
                  ),
                  Text(
                    widget.artist,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.normal),
                  )
                ],
              ),
            ),
            Text(
              _utils.intToTimeLeft(widget.duration),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
/**
  * ListTile(
            leading: QueryArtworkWidget(
              id: widget.songIndex,
              type: ArtworkType.AUDIO,
              artworkBorder: BorderRadius.circular(10),
            ),
            title: Text(
              widget.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.normal),
            ),
            trailing: Text(
              _utils.intToTimeLeft(widget.duration),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ))
 */