import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});
  
void logout(BuildContext context) {
  FirebaseAuth.instance.signOut();
  Navigator.pushReplacementNamed(context, '/login_register_page');
}

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NotesFolders'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.edit_document),
            title: Text('All Notes'),
            onTap: () {
              // Implement navigation to notifications settings
            },
          ),
          Divider(), // Divider after All Notes
          ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Favorites'),
            onTap: () {
              // Implement navigation to theme settings
            },
          ),
          Divider(), // Divider after Favorites
          ListTile(
            leading: Icon(Icons.folder_copy_rounded),
            title: Text('Folders'),
            onTap: () {
              // Implement navigation to privacy settings
            },
          ),
          Divider(), // Divider after Folders
          ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Recently Deleted'),
            onTap: () {
              // Implement navigation to about page
            },
          ),
          Divider(), // Divider after Recently Deleted
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Implement navigation to help and feedback page
            },
          ),
          Divider(), // Divider after Settings
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          Divider(), // Divider after Logout
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
onPressed: () {
  Navigator.of(context).pop(); // Close the dialog
  logout(context);
},

            ),
          ],
        );
      },
    );
  }

}
