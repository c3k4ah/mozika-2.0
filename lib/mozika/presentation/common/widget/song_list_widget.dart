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
  final VoidCallback onPressed;

  const WidgetOfSongListe(
      {super.key,
      required this.data,
      required this.index,
      required this.isPlay,
      required this.title,
      required this.duration,
      required this.songIndex,
      required this.onPressed});

  @override
  State<WidgetOfSongListe> createState() => _WidgetOfSongListeState();
}

class _WidgetOfSongListeState extends State<WidgetOfSongListe> {
  final CustomSize _size = CustomSize();
  final Utils _utils = Utils();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 50,
      width: _size.width(context),
      padding: EdgeInsets.zero,
      child: Center(
        child: ListTile(
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
            )),
      ),
    );
  }
}
/**
  * IconButton(
              onPressed: widget.onPressed,
              icon: Icon(
                widget.isPlay
                    ? FluentSystemIcons.ic_fluent_pause_filled
                    : FluentSystemIcons.ic_fluent_play_filled,
                color: Colors.white30,
                size: 25,
              ))
 */