import 'package:flutter/material.dart';
import 'package:mozika/mozika/presentation/common/widget/size.dart';

import '../constant/colors.dart';
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
      child: ListTile(
          leading: IconButton(
              onPressed: widget.onPressed,
              icon: Icon(
                widget.isPlay ? Icons.pause_outlined : Icons.play_arrow,
                color: primary,
                size: 30,
              )),
          title: Text(
            widget.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ),
          trailing: Text(
            _utils.intToTimeLeft(widget.duration),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          )),
    );
  }
}
