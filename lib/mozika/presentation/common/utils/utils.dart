class Utils {
  static String getDurationString(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  static String getDurationStringFromSeconds(int seconds) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits((seconds / 60).floor());
    String twoDigitSeconds = twoDigits(seconds % 60);
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String intToTimeLeft(int value) {
    //la valeur est en millisecondes
    int h, m, s;
    //puisque la valeur est en millisecondes, on divise par 1000 pour avoir les secondes
    double toSeconde = value / 1000;
    //conversion en heure
    h = toSeconde ~/ 3600;
    //conversion en minute
    m = ((toSeconde - h * 3600)) ~/ 60;
    //conversion en seconde
    s = (toSeconde - (h * 3600) - (m * 60)).toInt();
    //mise en forme en chaine de caractère
    String hourLeft = h.toString().length < 2 ? "0$h" : h.toString();
    String minuteLeft = m.toString().length < 2 ? "0$m" : m.toString();
    String secondsLeft = s.toString().length < 2 ? "0$s" : s.toString();

    //retourne la valeur en format hh:mm:ss
    String result = "$hourLeft:$minuteLeft:$secondsLeft";
    if (hourLeft == "00") {
      //retourne la valeur en format mm:ss si l'heure est à 00
      result = "$minuteLeft:$secondsLeft";
    } else if (minuteLeft == "00" && hourLeft == "00") {
      //retourne la valeur en format ss si l'heure et la minute sont à 00
      result = secondsLeft;
    } else {
      return result;
    }
    return result;
  }
}
