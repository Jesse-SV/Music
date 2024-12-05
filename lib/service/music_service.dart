import 'package:musicabdlocal/helpers/music_helper.dart';

class MusicService {
  final MusicHelper _musicHelper = MusicHelper();

  Future<bool> isDuplicate(String name, String artist) async {

    List<Music> allMusics = await _musicHelper.getAllMusics();

    for (Music music in allMusics) {
      if (music.name.toLowerCase() == name.toLowerCase() &&
          music.artist.toLowerCase() == artist.toLowerCase()) {
        return true;
      }
    }

    return false;
  }
}
