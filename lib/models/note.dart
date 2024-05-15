class Note {
  int id;
  String title;
  String content;
  DateTime modifiedTime;
  String category; // Add category field

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.modifiedTime,
    required this.category, // Initialize category in the constructor
  });
}
