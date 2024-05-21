import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:note_flutter/database/firestore.dart';
import 'package:note_flutter/features/audio.dart';
import 'package:note_flutter/features/camera.dart';
import 'package:note_flutter/models/category.dart';
import 'package:note_flutter/screens/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/note.dart';
import 'dart:ui' as ui;

class EditScreen extends StatefulWidget {
  final Note? note;
  final List<Note> notes;
  final String? noteId;

  const EditScreen({Key? key, this.note, required this.notes, this.noteId})
      : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<Category> _categories = [];
  String? _imagePath;
  String? _audioPath;
  String? _sketchPath;
  FlutterSoundPlayer? _player;
  final _signKey = GlobalKey<SignatureState>();
  bool _isSketchVisible = false;
  final User? user = FirebaseAuth.instance.currentUser;
  final FirestoreDatabase firestoreDatabase = FirestoreDatabase();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    if (widget.note != null) {
      _imagePath = widget.note!.imagePath;
      _audioPath = widget.note!.audioPath;
      _sketchPath = widget.note!.sketchPath;
    }
    _player = FlutterSoundPlayer();
    _player!.openPlayer().then((value) {
      setState(() {});
    });
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    List<Category> categories = await firestoreDatabase.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _player!.closePlayer();
    super.dispose();
  }

  void _recordAudio() async {
    final audioPath = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AudioScreen()),
    );
    if (audioPath != null) {
      setState(() {
        _audioPath = audioPath;
      });
    }
  }

  void _playAudio() async {
    if (_audioPath != null && await File(_audioPath!).exists()) {
      await _player!.startPlayer(
        fromURI: _audioPath!,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        },
      );
    }
  }

  Future<String?> _showCategoryInputDialog(BuildContext context) async {
    TextEditingController categoryController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(hintText: 'Enter category name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                Navigator.of(context).pop(categoryController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<DocumentReference?> _showExistingCategoryDialog(
      BuildContext context) async {
    return showDialog<DocumentReference>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _categories.map((category) {
                return ListTile(
                  title: Text(category.name),
                  onTap: () {
                    var categoryRef = FirebaseFirestore.instance
                        .collection('Categories')
                        .doc(category.id);
                    Navigator.of(context).pop(categoryRef);
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNote() async {
    try {
      String? imageUrl;
      String? audioUrl;
      String? sketchUrl;

      if (_imagePath != null) {
        imageUrl = await _uploadFile(File(_imagePath!),
            'images/${DateTime.now().toIso8601String()}.png');
        print("Image URL: $imageUrl");
      }

      if (_audioPath != null) {
        audioUrl = await _uploadFile(File(_audioPath!),
            'audios/${DateTime.now().toIso8601String()}.aac');
        print("Audio URL: $audioUrl");
      }

      if (_sketchPath != null) {
        sketchUrl = await _uploadFile(File(_sketchPath!),
            'sketches/${DateTime.now().toIso8601String()}.png');
        print("Sketch URL: $sketchUrl");
      }

      Note newNote = Note(
        id: '',
        title: _titleController.text,
        content: _contentController.text,
        categoryId: null,
        modifiedTime: DateTime.now(),
        imagePath: imageUrl,
        audioPath: audioUrl,
        sketchPath: sketchUrl,
      );

      bool addCategory = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add to Category'),
                content: Text('Do you want to add this note to a category?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          ) ??
          false;

      if (addCategory) {
        DocumentReference? selectedCategoryId;
        bool addToExistingCategory = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Choose Category Option'),
                  content: Text(
                      'Do you want to add this note to an existing category or create a new category?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Existing Category'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                    TextButton(
                      child: Text('New Category'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                );
              },
            ) ??
            false;

        if (addToExistingCategory) {
          selectedCategoryId = await _showExistingCategoryDialog(context);
        } else {
          String? newCategoryName = await _showCategoryInputDialog(context);
          if (newCategoryName != null && newCategoryName.isNotEmpty) {
            Category newCategory = Category(id: '', name: newCategoryName);
            var createdCategory = await firestoreDatabase.createCategory(newCategory);
            setState(() {
              _categories.add(newCategory);
            });

            FirebaseFirestore.instance
                .collection('Categories')
                .doc(createdCategory.id);

            selectedCategoryId = createdCategory;
          }
        }

        if (selectedCategoryId != null) {
          newNote = newNote.copyWith(categoryId: selectedCategoryId);
        }
      }

      if (widget.noteId != null) {
        await firestoreDatabase.updateNote(widget.noteId!, newNote);
      } else {
        await firestoreDatabase.createNote(newNote);
      }

      Navigator.pop(context);
    } catch (e) {
      print("Error saving note: $e");
    }
  }

  Future<String> _uploadFile(File file, String path) async {
    try {
      final storageReference = FirebaseStorage.instance.ref().child(path);
      final uploadTask = storageReference.putFile(file);
      final taskSnapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print("No object exists at the desired reference: $path");
      } else {
        print("Error uploading file: $e");
      }
      throw e;
    } catch (e) {
      print("Error uploading file: $e");
      throw e;
    }
  }

  Future<void> _takePhoto() async {
    await availableCameras().then((cameras) async {
      final imagePath = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraPage(cameras: cameras)),
      );
      if (imagePath != null) {
        setState(() {
          _imagePath = imagePath;
        });
      }
    });
  }

  void _toggleSketchPad() {
    setState(() {
      _isSketchVisible = !_isSketchVisible;
    });
  }

  Future<void> _saveSketch() async {
    final sign = _signKey.currentState!;
    final image = await sign.getData();
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);

    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await file.writeAsBytes(data!.buffer.asUint8List());
    setState(() {
      _sketchPath = path;
      _isSketchVisible = false;
    });
  }

  void _deleteNote() {
    if (widget.note != null && widget.noteId != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete Note"),
            content: Text("Are you sure you want to delete this note?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  List<Note> updatedNotes = List.from(widget.notes);
                  if (widget.note != null) {
                    updatedNotes.remove(widget.note);
                    await firestoreDatabase.deleteNote(widget.noteId!);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(
                              notes: updatedNotes,
                              firestoreDatabase: FirestoreDatabase())),
                    );
                  }
                },
                child: Text("Delete"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.grey.shade800,
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                _saveNote, // Call _saveNote when the "Save" button is pressed
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey.shade800,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Note'),
                  onTap: () {
                    // Implement share note functionality
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: Text('Search'),
                  onTap: () {
                    // Implement search functionality
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.favorite_border),
                  title: Text('Add to Favorites'),
                  onTap: () {
                    // Implement add to favorites functionality
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                  onTap:
                      _deleteNote, // Call _deleteNote when "Delete" is tapped
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.black, fontSize: 30),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Title',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 30),
                    ),
                  ),
                  TextField(
                    controller: _contentController,
                    style: const TextStyle(color: Colors.black),
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type something here',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  if (_imagePath != null) ...[
                    const SizedBox(height: 10),
                    Image.network(_imagePath!, fit: BoxFit.cover),
                  ],
                  if (_audioPath != null) ...[
                    const SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.audiotrack, color: Colors.grey),
                      title: Text('Recorded Audio'),
                      trailing: IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: _playAudio, // Play the recorded audio
                      ),
                    ),
                  ],
                  if (_sketchPath != null && widget.note?.sketchPath == null) ...[
                    const SizedBox(height: 10),
                    Image.file(File(_sketchPath!), fit: BoxFit.cover),
                  ],
                   if (widget.note?.sketchPath != null) ...[
                    const SizedBox(height: 10),
                    Image.network(widget.note!.sketchPath!, fit: BoxFit.cover),
                  ],
                  if (_isSketchVisible) ...[
                    const SizedBox(height: 10),
                    Container(
                      height: 300.0,
                      color: Colors.white,
                      child: Signature(
                        key: _signKey, // Assigning GlobalKey
                        strokeWidth: 2.0,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            final sign = _signKey.currentState!;
                            sign.clear(); // Clear the sketch pad
                          },
                          child: Text('Clear'),
                        ),
                        TextButton(
                          onPressed: _saveSketch, // Save the sketch
                          child: Text('Save Sketch'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: _takePhoto,
                  icon: Icon(Icons.camera_alt),
                  tooltip: 'Take Photo',
                ),
                IconButton(
                  onPressed: _recordAudio, // Navigate to audio recording screen
                  icon: Icon(Icons.mic),
                  tooltip: 'Record Audio',
                ),
                IconButton(
                  onPressed: _toggleSketchPad, // Toggle sketch pad visibility
                  icon: Icon(Icons.edit),
                  tooltip: 'Sketch',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
