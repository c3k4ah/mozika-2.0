import 'package:flutter/material.dart';

import 'mozika/presentation/track_liste/track_liste.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mozika',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TrackListe(),
    );
  }
}
