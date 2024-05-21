import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:note_flutter/auth/auth.dart';
import 'package:note_flutter/auth/login_or_register.dart';
import 'package:note_flutter/database/firestore.dart';
import 'package:note_flutter/firebase_options.dart';
import 'package:note_flutter/models/note.dart';
import 'package:note_flutter/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp(notesList: [],));
}

class MainApp extends StatelessWidget {
  final List<Note> notesList;

  const MainApp({Key? key, required this.notesList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => HomeScreen(
          notes: notesList, 
          firestoreDatabase: FirestoreDatabase(), // Pass firestoreDatabase here
        ),
        // Add other routes as needed
      },
    );
  }
}


