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
        title: const Text('NotesFolders'),
        backgroundColor: Colors.blueGrey.shade400,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildListTile(
            context,
            icon: Icons.edit_document,
            title: 'All Notes',
            onTap: () {
              // Implement navigation to All Notes
            },
          ),
          _buildDivider(),
          _buildListTile(
            context,
            icon: Icons.folder_copy_rounded,
            title: 'Folders',
            onTap: () {
              // Implement navigation to Folders
            },
          ),
          _buildDivider(),
          _buildListTile(
            context,
            icon: Icons.delete_outline,
            title: 'Recently Deleted',
            onTap: () {
              // Implement navigation to Recently Deleted
            },
          ),
          _buildDivider(),
          _buildListTile(
            context,
            icon: Icons.supervised_user_circle_rounded,
            title: 'Profile',
            onTap: () {
              // Implement navigation to Settings
            },
          ),
          _buildDivider(),
          _buildListTile(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey.shade400),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 1.0,
      height: 1.0,
      indent: 16.0,
      endIndent: 16.0,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
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
