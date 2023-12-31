import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'Ryan_Message_History.dart';
import 'login.dart';
import 'userData.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'TutorDisplay.dart';
import 'settings.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  bool messageNotification = true; // Default value for Message notification
  bool appointmentReminderNotification = true; // Default value for Appointment Reminder notification

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Upload the selected image to Firebase Storage
      // ...

      final FirebaseAuth auth = FirebaseAuth.instance;

      try {
        final File file = File(pickedImage.path);
        final String fileName = basename(file.path);
        final destination = 'public/images/${auth.currentUser?.uid ?? ""}';

        final ref = FirebaseStorage.instance
            .ref()
            .child(destination);
        await ref.putFile(file);
      } on FirebaseException catch (e) {
        print("Failed with error '${e.code}': ${e.message}");
      }

      // Get the download URL of the uploaded image
      String downloadUrl = '...'; // Replace with actual download URL

      // Access the UserData class and set the image
      Provider.of<UserData>(context, listen: false).setImage(File(pickedImage.path), downloadUrl);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) => false
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
        title: Align(
          alignment: Alignment.bottomLeft,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage(title: "")),
              );
            },
            child: Image(
              image: NetworkImage(
                  "https://dlmrue3jobed1.cloudfront.net/uploads/school/SouthernNewHampshireUniversity/snhu_initials_rgb_pos.png"),
              width: 300,
              height: 100,
            ),
          ),
        ),
        flexibleSpace: Container(decoration: BoxDecoration(color: Color(0xff009DEA))),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: userData.image != null
                  ? NetworkImage(userData.imageUrl!)/*FileImage(userData.image!)*/
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
              /*
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
              ), */
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
      bottomNavigationBar: BottomNavigationBar( //Navigation bar. Something like this will be on every page
        backgroundColor: Color(0xffFDB913),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "")
        ],
        onTap: (int index) {
          if (index == 2) { // Index 2 corresponds to the "settings" icon
            // Navigate to the settings page when the "settings" icon is tapped.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }
          if (index == 1) { // Index 1 corresponds to the "Chat" icon
            // Navigate to the ChatScreen when the "Chat" icon is tapped.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RyanMessageState()),
            );
          }
          if(index == 0){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TutorState(title: "")), //change it to your setting page
            );
          }
        },
      ),
    );
  }
}
