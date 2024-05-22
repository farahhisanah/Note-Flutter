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

final CollectionReference calendar =
      FirebaseFirestore.instance.collection('Calendar');

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


  Future<void> addEventToCalendar(DateTime date, String eventText) async {
    try {
      await calendar.add({
        'date': date,
        'event': eventText,
      });
    } catch (e) {
      print('Error adding event to calendar: $e');
      throw e;
    }
  }

Future<Map<DateTime, List<String>>> fetchEvents() async {
  try {
    QuerySnapshot<Object?> snapshot = await _firestore.collection('Calendar').get();
    Map<DateTime, List<String>> eventsMap = {};
    snapshot.docs.forEach((doc) {
      // Convert Firestore Timestamp to DateTime
      DateTime date = (doc['date'] as Timestamp).toDate();
      String event = doc['event'] as String;
      eventsMap[date] = eventsMap[date] ?? [];
      eventsMap[date]!.add(event);
    });
    return eventsMap;
  } catch (e) {
    print('Error fetching events: $e');
    throw e;
  }
}


Future<void> updateEventInCalendar(DateTime date, String oldEvent, String newEvent) async {
    try {
      // Query for the event document that matches the date and old event
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Calendar')
          .where('date', isEqualTo: date)
          .where('event', isEqualTo: oldEvent)
          .get();

      // Update the event document with the new event text
      snapshot.docs.forEach((doc) async {
        await doc.reference.update({'event': newEvent});
      });
    } catch (error) {
      print('Error updating event in calendar: $error');
      throw error;
    }
  }

Future<void> deleteEventInCalendar(DateTime date, String event) async {
  try {
    // Query for the event document that matches the date and event text
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('Calendar')
        .where('date', isEqualTo: date)
        .where('event', isEqualTo: event)
        .get();

    // Delete the event document
    snapshot.docs.forEach((doc) async {
      await doc.reference.delete();
    });
  } catch (error) {
    print('Error deleting event in calendar: $error');
    throw error;
  }
}

  
}
