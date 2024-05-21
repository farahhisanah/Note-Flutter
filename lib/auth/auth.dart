import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_flutter/database/firestore.dart';
import 'package:note_flutter/screens/home.dart';
import 'package:note_flutter/screens/login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return HomeScreen(
              notes: [], // Pass an empty list of notes
              firestoreDatabase: FirestoreDatabase(), // Pass firestoreDatabase here
            );
          }
          // user is not logged in
          else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}


