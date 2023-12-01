import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'userData.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool messageNotification = true; // Default value for Message notification
  bool appointmentReminderNotification = true; // Default value for Appointment Reminder notification

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Upload the selected image to Firebase Storage
      // ...

      // Get the download URL of the uploaded image
      String downloadUrl = '...'; // Replace with actual download URL

      // Access the UserData class and set the image
      Provider.of<UserData>(context, listen: false).setImage(File(pickedImage.path), downloadUrl);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the UserData class to get the image and imageUrl
    final userData = Provider.of<UserData>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: userData.image != null
                  ? FileImage(userData.image!)
                  : NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Windows_10_Default_Profile_Picture.svg/2048px-Windows_10_Default_Profile_Picture.svg.png') as ImageProvider<Object>,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            children: <Widget>[
              ListTile(
                title: Text('Change Profile Picture'),
                onTap: () {
                  _pickImage(context);
                },
              ),
              SwitchListTile(
                title: Text('Message Notifications'),
                value: messageNotification,
                onChanged: (value) {
                  setState(() {
                    messageNotification = value;
                    // Implement logic for handling Message notification toggle change
                  });
                },
              ),
              SwitchListTile(
                title: Text('Appointment Reminder'),
                value: appointmentReminderNotification,
                onChanged: (value) {
                  setState(() {
                    appointmentReminderNotification = value;
                    // Implement logic for handling Appointment Reminder notification toggle change
                  });
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
        ],
      ),
    );
  }
}
