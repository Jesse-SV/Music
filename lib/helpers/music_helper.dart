import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

String idColumn = "idColumn";
String nameColumn = "nameColumn";
String artistColumn = "artistColumn";
String genreColumn = "genreColumn";
String releaseDateColumn = "releaseDateColumn";
String albumColumn = "albumColumn";
String musicTable = "MusicTable";

class MusicHelper {
  static final MusicHelper _instance = MusicHelper.internal();
  factory MusicHelper() => _instance;
  MusicHelper.internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "music.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newVersion) async {
        await db.execute(
            "CREATE TABLE $musicTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $artistColumn TEXT, $genreColumn TEXT, $releaseDateColumn TEXT, $albumColumn TEXT)");
      },
    );
  }

  Future<List<Music>> getAllMusics() async {
    Database dbMusic = await db;
    List<Map<String, dynamic>> listMap = await dbMusic.rawQuery("SELECT * FROM $musicTable");
    List<Music> listMusic = [];
    for (Map<String, dynamic> m in listMap) {
      listMusic.add(Music.fromMap(m));
    }
    return listMusic;
  }

  Future<Music?> getMusic(int id) async {
    Database dbMusic = await db;
    List<Map<String, dynamic>> maps = await dbMusic.query(
      musicTable,
      columns: [idColumn, nameColumn, artistColumn, genreColumn, releaseDateColumn, albumColumn],
      where: "$idColumn = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Music.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Music> saveMusic(Music music) async {
    Database dbMusic = await db;
    music.id = await dbMusic.insert(musicTable, music.toMap());
    return music;
  }

  Future<int> updateMusic(Music music) async {
    Database dbMusic = await db;
    return await dbMusic.update(
      musicTable,
      music.toMap(),
      where: "$idColumn = ?",
      whereArgs: [music.id],
    );
  }

  Future<int> deleteMusic(int id) async {
    Database dbMusic = await db;
    return await dbMusic.delete(
      musicTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }
}

class Music {
  int? id;
  String name = '';
  String artist = '';
  String genre = '';
  String releaseDate = '';
  String album = '';

  Music();

  Music.fromMap(Map<String, dynamic> map) {
    id = map[idColumn];
    name = map[nameColumn] ?? '';
    artist = map[artistColumn] ?? '';
    genre = map[genreColumn] ?? '';
    releaseDate = map[releaseDateColumn] ?? '';
    album = map[albumColumn] ?? '';
  }

  Map<String, dynamic> toMap() {
    final Map<String,dynamic> map = {
      nameColumn: name,
      artistColumn: artist,
      genreColumn: genre,
      releaseDateColumn: releaseDate,
      albumColumn: album,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }


  @override
  String toString() {
    return "Music(id: $id, name: $name, artist: $artist, genre: $genre, releaseDate: $releaseDate, album: $album)";
  }
}
