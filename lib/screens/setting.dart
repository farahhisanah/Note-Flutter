import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
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
            leading: Icon(Icons.list_alt_outlined),
            title: Text('To do lists'),
            onTap: () {
              // Implement navigation to privacy settings
            },
          ),
          Divider(), // Divider after To do lists
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
          Divider(), 
        ],
      ),
    );
  }
}
