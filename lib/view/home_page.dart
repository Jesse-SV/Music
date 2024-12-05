import 'package:flutter/material.dart';
import 'package:musicabdlocal/helpers/music_helper.dart';
import 'package:musicabdlocal/view/music_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MusicHelper helper = MusicHelper();
  List<Music> musics = [];

  @override
  void initState(){
    super.initState();
    _getAllMusics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Minhas músicas",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 73, 158),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 27, 27, 30),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            _showMusicPage();
          },
          child: Icon(Icons.music_note, color: Color.fromARGB(255, 27, 27, 30),),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: musics.length,
        itemBuilder: (context, index){
          return _musicCard(context, index);
        },
      ),
    );
  }

  Widget _musicCard(BuildContext context, int index) {
  return GestureDetector(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              musics[index].name,
              style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            Text(
              "Artista: ${musics[index].artist}",
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              "Gênero: ${musics[index].genre}",
              style: const TextStyle(fontSize: 17.0),
            ),
            Text(
              "Álbum: ${musics[index].album}",
              style: const TextStyle(fontSize: 17.0),
            ),
            Text(
              "Data de Lançamento: ${musics[index].releaseDate}",
              style: const TextStyle(fontSize: 17.0),
            ),
          ],
        ),
      ),
    ),
    onTap: () {
      _showOptions(context, index);
    },
  );
}

void _showMusicPage({Music? music}) async {
  final recMusic = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MusicPage(music: music)),
  );
  if (recMusic != null) {
    if (recMusic.id != null) {
      await helper.updateMusic(recMusic);
    } else {
      await helper.saveMusic(recMusic);
    }
    _getAllMusics();
  }
}

  void _getAllMusics(){
    helper.getAllMusics().then((list){
      setState(() {
        musics = list;
      });
    },);
  }

void _showOptions(BuildContext context, int index) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: const Text(
          "Opções",
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showMusicPage(music: musics[index]);
              },
              child: const Text(
                "Editar",
                style: TextStyle(fontSize: 18.0, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(color: Colors.grey),
            TextButton(
              onPressed: () {
                _showConfirmationDialog(context, index);
              },
              child: const Text(
                "Excluir",
                style: TextStyle(fontSize: 18.0, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showConfirmationDialog(BuildContext context, int index) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: const Text(
          "Confirmação",
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          "Tem certeza de que deseja excluir esta música?",
          style: TextStyle(fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.grey, fontSize: 18.0),
            ),
          ),
          TextButton(
            onPressed: () {
              helper.deleteMusic(musics[index].id!);
              setState(() {
                musics.removeAt(index);
                Navigator.pop(context);
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Confirmar",
              style: TextStyle(color: Colors.red, fontSize: 18.0),
            ),
          ),
        ],
      );
    },
  );
}


}