import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_flutter/constants/colors.dart';
import 'package:note_flutter/database/firestore.dart';
import 'package:note_flutter/features/calendar.dart';
import 'package:note_flutter/models/category.dart';
import 'package:note_flutter/models/note.dart';
import 'package:note_flutter/screens/edit.dart';
import 'package:note_flutter/screens/setting.dart';

class HomeScreen extends StatefulWidget {
  final List<Note> notes;
  final FirestoreDatabase firestoreDatabase;

  const HomeScreen(
      {Key? key, required this.notes, required this.firestoreDatabase})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;

  List<Note> notes = [];
  List<Note> filteredNotes = [];
  bool sorted = false;
  String? selectedCategory = null;
  String searchQuery = '';
  List<Category?> _categories = [];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await widget.firestoreDatabase
          .fetchData(); // Fetch data from FirestoreDatabase
      _fetchNotes();
      _fetchCategories();
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _fetchNotes() {
    try {
      widget.firestoreDatabase.getNotesStream().listen((querySnapshot) {
        List<Note> fetchedNotes = querySnapshot.docs.map((doc) {
          return Note.fromFirestore(doc);
        }).toList();
        setState(() {
          notes = fetchedNotes;
          filteredNotes = notes;
        });
      });
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      List<Category?> categories = [null];
      categories.addAll(await widget.firestoreDatabase.getCategories());
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void sortNotesByModifiedTime() {
    notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    if (!sorted) notes = notes.reversed.toList();
    sorted = !sorted;
    filterNotesByCategory(selectedCategory);
  }

  void filterNotesByCategory(String? category) {
    setState(() {
      selectedCategory = category;
      filteredNotes = notes.where((note) {
        if(selectedCategory == null) {
          return true;
        } else {
          return note.categoryId?.id == selectedCategory;
        }
      }).toList();
    });
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filterNotesByCategory(selectedCategory);
    });
  }

  Color getRandomColor() {
    Random random = Random();
    int index = random.nextInt(backgroundColors.length);
    return backgroundColors[index];
  }

  Future<void> _addOrEditNote([Note? note]) async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(note: note, notes: notes),
      ),
    );

    if (result != null) {
      setState(() {
        if (note == null) {
          notes.add(result);
        } else {
          final index = notes.indexOf(note);
          notes[index] = result;
        }
        filterNotesByCategory(selectedCategory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingScreen(),
                      ),
                    );
                  },
                ),
                Text(
                  'Notes',
                  style: TextStyle(fontSize: 30, color: Colors.grey.shade800),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          sortNotesByModifiedTime();
                        });
                      },
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800.withOpacity(.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.sort,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CalendarScreen(),
                          ),
                        );
                      },
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800.withOpacity(.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: "Search notes",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.grey.shade300,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  return CategoryContainer(
                    category: category?.name ?? 'ALL',
                    isSelected: selectedCategory == category?.id,
                    onTap: (categoryId) => filterNotesByCategory(categoryId),
                    categoryId: category?.id,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  return GestureDetector(
                    onTap: () => _addOrEditNote(note),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      color: getRandomColor(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        height:
                            130, // Set the desired height for all cards here
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.title,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        height: 1.5,
                                      ),
                                    ),
                                    if (note.content.isNotEmpty)
                                      Text(
                                        note.content,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                        maxLines:
                                            3, // Control number of lines displayed
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Last edited: ${DateFormat('yyyy-MM-dd – kk:mm').format(note.modifiedTime)}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (note.imagePath != null || note.sketchPath != null)
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Stack(
                                    children: [
                                      if (note.imagePath != null)
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              (note.imagePath!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      if (note.sketchPath != null)
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              (note.sketchPath!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class CategoryContainer extends StatelessWidget {
  final String category;
  final bool isSelected;
  final String? categoryId; // New field to hold the category ID
  final void Function(String?) onTap;

  const CategoryContainer({
    required this.category,
    required this.isSelected,
    required this.categoryId, // Assign the category ID
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(categoryId); // Pass the category ID when tapped
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueGrey.shade300 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade800,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
