import 'package:cloud_firestore/cloud_firestore.dart';

// Category Model
class Category {
  String id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}