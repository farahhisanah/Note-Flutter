import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:note_flutter/features/camera.dart';
import '../models/note.dart';

class EditScreen extends StatefulWidget {
  final Note? note;
  final XFile picture;
  const EditScreen({Key? key, this.note, required this.picture}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
  }

  class _EditScreenState extends State<EditScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'Uncategorized'; // Default category

  @override
  void initState() {
    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
      _selectedCategory = widget.note!.category;
    }

    super.initState();
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
            onPressed: () {
              Navigator.pop(
                context,
                [_titleController.text, _contentController.text],
              );
            },
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
                  onTap: () {
                    // Implement delete functionality
                  },
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
                Image.file(File(widget.picture.path), fit: BoxFit.cover, width: 250),
                const SizedBox(height: 24),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () async {
                    await availableCameras().then((value) => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));
                  },
                  icon: Icon(Icons.camera_alt),
                  tooltip: 'Take Photo',
                ),
                IconButton(
                  onPressed: () {
                    // Implement audio recording functionality here
                  },
                  icon: Icon(Icons.mic),
                  tooltip: 'Record Audio',
                ),
                IconButton(
                  onPressed: () {
                    // Implement text editing functionality here
                  },
                  icon: Icon(Icons.edit),
                  tooltip: 'Edit Text',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
