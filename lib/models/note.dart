import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DocumentReference? categoryId;
  final DateTime modifiedTime;
  final String? imagePath;
  final String? audioPath;
  final String? sketchPath;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.modifiedTime,
    this.imagePath,
    this.audioPath,
    this.sketchPath,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DocumentReference? categoryId,
    DateTime? modifiedTime,
    String? imagePath,
    String? audioPath,
    String? sketchPath,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      sketchPath: sketchPath ?? this.sketchPath,
    );
  }

  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    print(data);
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      categoryId: data['categoryId'],
      modifiedTime: (data['modifiedTime'] as Timestamp).toDate(),
      imagePath: data['imagePath'],
      audioPath: data['audioPath'],
      sketchPath: data['sketchPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'modifiedTime': Timestamp.fromDate(modifiedTime),
      'imagePath': imagePath,
      'audioPath': audioPath,
      'sketchPath': sketchPath,
    };
  }
}
