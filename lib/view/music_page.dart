import 'package:flutter/material.dart';
import 'package:musicabdlocal/helpers/music_helper.dart';
import 'package:musicabdlocal/service/music_service.dart';
import 'package:flutter/services.dart';

class MusicPage extends StatefulWidget {
  final Music? music;

  MusicPage({this.music});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  late Music _editedMusic;
  bool _userEdited = false;
  bool _isNameValid = true;
  bool _isArtistValid = true;
  bool _isGenreValid = true;
  bool _isReleaseDateValid = true;

  final _nameController = TextEditingController();
  final _artistController = TextEditingController();
  final _genreController = TextEditingController();
  final _releaseDateController = TextEditingController();
  final _albumController = TextEditingController();
  final _nameFocus = FocusNode();

  final MusicService _musicService = MusicService();

  @override
  void initState() {
    super.initState();
    if (widget.music == null) {
      _editedMusic = Music();
    } else {
      _editedMusic = Music.fromMap(widget.music!.toMap());
      _nameController.text = _editedMusic.name;
      _artistController.text = _editedMusic.artist;
      _genreController.text = _editedMusic.genre;
      _releaseDateController.text = _editedMusic.releaseDate;
      _albumController.text = _editedMusic.album;
    }
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Descartar Alterações"),
            content: const Text("Se sair as alterações serão perdidas!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Sim"),
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Future<void> _validateAndSaveMusic() async {
    setState(() {
      _isNameValid = _editedMusic.name.isNotEmpty;
      _isArtistValid = _editedMusic.artist.isNotEmpty;
      _isGenreValid = _editedMusic.genre.isNotEmpty;
      _isReleaseDateValid = _editedMusic.releaseDate.isNotEmpty;
    });

    if (!_isNameValid ||
        !_isArtistValid ||
        !_isGenreValid ||
        !_isReleaseDateValid) {
      FocusScope.of(context).requestFocus(_nameFocus);
      return;
    }

    DateTime releaseDate = DateTime.parse(_editedMusic.releaseDate);
    DateTime currentDate = DateTime.now();

    if (releaseDate.isAfter(currentDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "A data é inválida",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return; 
    }

    bool isDuplicate = await _musicService.isDuplicate(
      _editedMusic.name,
      _editedMusic.artist,
    );

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Já existe uma música com este nome e artista.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Navigator.pop(context, _editedMusic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 27, 27, 30),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 73, 158),
          title: Text(
            _editedMusic.name.isNotEmpty ? _editedMusic.name : "Nova Música",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _validateAndSaveMusic,
          child: Icon(
            Icons.save,
            color: Color.fromARGB(255, 27, 27, 30),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  height: 220.0,
                  child: Center(
                    child: Container(
                      width: 220.0,
                      height: 220.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8.0),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/musicNote.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              buildTextField(
                controller: _nameController,
                labelText: "Nome",
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedMusic.name = text;
                  });
                },
                errorText: _isNameValid ? null : "Nome é obrigatório",
              ),
              const SizedBox(height: 20.0),
              buildTextField(
                controller: _artistController,
                labelText: "Artista",
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedMusic.artist = text;
                  });
                },
                errorText: _isArtistValid ? null : "Artista é obrigatório",
              ),
              const SizedBox(height: 20.0),
              DropdownButtonFormField<String>(
                value:
                    _editedMusic.genre.isNotEmpty ? _editedMusic.genre : null,
                decoration: InputDecoration(
                  labelText: "Gênero",
                  labelStyle:
                      const TextStyle(color: Color.fromARGB(150, 255, 73, 158)),
                  border: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 255, 73, 158),
                        width: 2.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  errorText: _isGenreValid ? null : "Gênero é obrigatório",
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _userEdited = true;
                    _editedMusic.genre = newValue ?? '';
                  });
                },
                items: ['Pop', 'Rock', 'Hip-hop', 'Jazz', 'Classical', 'Reggae']
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: value == _editedMusic.genre
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20.0),
              buildTextField(
                controller: _releaseDateController,
                labelText: "Data de Lançamento",
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedMusic.releaseDate = text;
                  });
                },
                readOnly: true,
                isDateField: true,
                errorText: _isReleaseDateValid ? null : "Data é obrigatória",
              ),
              const SizedBox(height: 20.0),
              buildTextField(
                controller: _albumController,
                labelText: "Álbum",
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedMusic.album = text;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required Function(String) onChanged,
    bool readOnly = false,
    bool isDateField = false,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color.fromARGB(150, 255, 73, 158)),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: const Color.fromARGB(255, 255, 73, 158), width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorText: errorText,
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(30),
      ],
      onChanged: onChanged,
      onTap: isDateField
          ? () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      primaryColor: const Color.fromARGB(255, 255, 73, 158),
                      colorScheme: ColorScheme.light(
                          primary: const Color.fromARGB(255, 255, 73, 158)),
                      buttonTheme: const ButtonThemeData(
                          textTheme: ButtonTextTheme.primary),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                setState(() {
                  controller.text = formattedDate;
                  _editedMusic.releaseDate = formattedDate;
                  _userEdited = true;
                });
              }
            }
          : null,
    );
  }
}
