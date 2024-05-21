import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_flutter/models/note.dart';
import 'package:note_flutter/models/category.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('Notes');
  final CollectionReference categories =
      FirebaseFirestore.instance.collection('Categories');

  Future<void> fetchData() async {
    await _fetchNotes();
    await _fetchCategories();
  }

  Future<void> _fetchNotes() async {
    try {
      QuerySnapshot<Object?> snapshot = await notes.get();
      List<Note> notesList =
          snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
      // Update notes list accordingly
    } catch (e) {
      print('Error fetching notes: $e');
      throw e;
    }
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot<Object?> snapshot = await categories.get();
      List<Category> categoriesList =
          snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      // Update categories list accordingly
    } catch (e) {
      print('CATEGORY ERROR');
      print('Error fetching categories: $e');
      throw e;
    }
  }

  Future<void> createNote(Note note) async {
    try {
      await notes.add({
        'userEmail': user!.email,
        'title': note.title,
        'content': note.content,
        'categoryId': note.categoryId,
        'imagePath': note.imagePath,
        'audioPath': note.audioPath,
        'sketchPath': note.sketchPath,
        'modifiedTime': Timestamp.now(),
      });
    } catch (e) {
      print('Error creating note: $e');
      throw e;
    }
  }

  Future<void> updateNote(String noteId, Note note) async {
    try {
      await notes.doc(noteId).update({
        'title': note.title,
        'content': note.content,
        'categoryId': note.categoryId,
        'imagePath': note.imagePath,
        'audioPath': note.audioPath,
        'sketchPath': note.sketchPath,
        'modifiedTime': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating note: $e');
      throw e;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await notes.doc(noteId).delete();
    } catch (e) {
      print('Error deleting note: $e');
      throw e;
    }
  }

  Stream<QuerySnapshot> getNotesStream() {
    try {
      return notes
          .where('userEmail', isEqualTo: user!.email)
          .orderBy('modifiedTime', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting notes stream: $e');
      throw e;
    }
  }

  Future<DocumentReference> createCategory(Category category) async {
    try {
      return await categories.add(category.toMap());
    } catch (e) {
      print('Error creating category: $e');
      throw e;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      QuerySnapshot snapshot = await categories.get();
      return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting categories: $e');
      throw e;
    }
  }

  Future<void> updateCategory(String id, Category category) async {
    try {
      await categories.doc(id).update(category.toMap());
    } catch (e) {
      print('Error updating category: $e');
      throw e;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await categories.doc(id).delete();
    } catch (e) {
      print('Error deleting category: $e');
      throw e;
    }
  }

  Future<List<Note>> getNotesByCategory(String categoryId) async {
    try {
      QuerySnapshot snapshot =
          await notes.where('categoryId', isEqualTo: categoryId).get();
      return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting notes by category: $e');
      throw e;
    }
  }
}
