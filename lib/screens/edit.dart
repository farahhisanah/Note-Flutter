import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart'; // Import the package
import 'package:note_flutter/features/audio.dart';
import 'package:note_flutter/features/camera.dart';
import 'package:note_flutter/screens/home.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import 'dart:ui' as ui;

class EditScreen extends StatefulWidget {
  final Note? note;
  final List<Note> notes;

  const EditScreen({Key? key, this.note, required this.notes}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedCategory = 'Uncategorized'; // Default category
  String? _imagePath; // To store the path of the captured image
  String? _audioPath; // To store the path of the recorded audio
  String? _sketchPath; // To store the path of the saved sketch
  FlutterSoundPlayer? _player;
  final _signKey = GlobalKey<SignatureState>(); // GlobalKey for SignaturePad
  bool _isSketchVisible = false; // State variable to control sketch pad visibility

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    if (widget.note != null) {
      _selectedCategory = widget.note!.category;
      _imagePath = widget.note!.imagePath; // Initialize imagePath if note is provided
      _audioPath = widget.note!.audioPath; // Initialize audioPath if note is provided
      _sketchPath = widget.note!.sketchPath; // Initialize sketchPath if note is provided
    }
    _player = FlutterSoundPlayer();
  }

  // Function to navigate to audio recording screen and handle recorded audio
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

  // Function to save note
  Future<void> _saveNote() async {
    // Save note
    String title = _titleController.text;
    String content = _contentController.text;
    if (_imagePath != null) {
      content += '\n![Image]($_imagePath)';
    }
    if (_audioPath != null) {
      content += '\n[Audio]($_audioPath)';
    }
    if (_sketchPath != null) {
      content += '\n![Sketch]($_sketchPath)';
    }

    Note newNote = Note(
      title: title,
      content: content,
      category: _selectedCategory,
      modifiedTime: DateTime.now(),
      imagePath: _imagePath,
      audioPath: _audioPath, // Include audioPath in the new note
      sketchPath: _sketchPath, // Include sketchPath in the new note
    );

    List<Note> updatedNotes = List.from(widget.notes);
    if (widget.note != null) {
      // Edit existing note
      int index = updatedNotes.indexOf(widget.note!);
      if (index != -1) {
        updatedNotes[index] = newNote;
      }
    } else {
      // Add new note
      updatedNotes.add(newNote);
    }

    // Navigate back to HomeScreen with the updated list of notes
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(notes: updatedNotes)),
    );
  }

  // Function to handle taking a photo
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

  // Function to toggle sketch pad visibility
  void _toggleSketchPad() {
    setState(() {
      _isSketchVisible = !_isSketchVisible;
    });
  }

  // Function to save sketch as image
  Future<void> _saveSketch() async {
    final sign = _signKey.currentState!;
    final image = await sign.getData();
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);

    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await file.writeAsBytes(data!.buffer.asUint8List());
    setState(() {
      _sketchPath = path;
      _isSketchVisible = false;
    });
  }

void _deleteNote() {
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
              onPressed: () {
                List<Note> updatedNotes = List.from(widget.notes);
                if (widget.note != null) {
                  // Remove the note from the list
                  updatedNotes.remove(widget.note);
                  // Navigate back to HomeScreen with the updated list of notes
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(notes: updatedNotes)),
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
            onPressed: _saveNote, // Call _saveNote when the "Save" button is pressed
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
                  onTap: _deleteNote, // Call _deleteNote when "Delete" is tapped
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
                    Image.file(File(_imagePath!), fit: BoxFit.cover),
                  ],
                  if (_audioPath != null) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      child: ListTile(
                        leading: Icon(Icons.audiotrack, color: Colors.grey),
                        title: Text('Recorded Audio'),
                      ),
                    ),
                  ],
                  if (_sketchPath != null) ...[
                    const SizedBox(height: 10),
                    Image.file(File(_sketchPath!), fit: BoxFit.cover),
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

