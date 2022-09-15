import 'package:flutter/material.dart';

import 'mozika/presentation/track_liste/play_song.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mozika',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red, fontFamily: "Charming"),
      home: const TrackListe(),
    );
  }
}
