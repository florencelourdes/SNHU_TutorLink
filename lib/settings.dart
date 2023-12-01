import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  File? _image; // Declare the variable to hold the selected image

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign the user out
      Navigator.pushReplacementNamed(context, '/=login'); // Replace '/login'
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // You may add the code to save or upload the selected image here.

      // Update the state with the selected image
      setState(() {
        _image = File(pickedImage.path);
      });

      // Trigger a rebuild of the widget
      Navigator.of(context).pop(); // Close the image picker if necessary
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Stack(
        children: [
          ListView(
            children: <Widget>[
              ListTile(
                title: Text('Change Profile Picture'),
                onTap: () {
                  _pickImage();
                },
              ),
              ListTile(
                title: Text('Notifications'),
                onTap: () {
                  // Add logic for managing notifications here
                },
              ),
              ListTile(
                title: Text('Log Out'),
                onTap: () {
                  logout(context);
                },
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null ? FileImage(_image!) as ImageProvider<Object> : AssetImage('assets/placeholder.png') as ImageProvider<Object>,
              ),
            ),
          ),
        ],
      ),
    );
  }
}






