import 'package:on_audio_query/on_audio_query.dart';

class TemporaryData {
  int currentIndex = 0; //current index of the playing songs
  List<SongModel> songs = []; //list of songs

  //update the current playing song index listener
  set setCurrentIndex(int index) {
    currentIndex = index;
  }

  //update the current playing song index listener
  int get getCurrentIndex => currentIndex;

  //update the current playing song index listener
  set setSongs(List<SongModel> songs) {
    this.songs = songs;
  }

  //update the current playing song index listener
  List<SongModel> get getSongs => songs;
}
