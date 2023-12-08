import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:snhu_tutorlink/userData.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore store = FirebaseFirestore.instance;

  Future<void> _login() async {
    try {
      UserCredential credentials =
      await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      store.collection('users').doc(credentials.user!.uid).set({
        'uid' : credentials.user!.uid,
        'email' : credentials.user!.email,
      }, SetOptions(merge: true));
      // If authentication is successful, you can navigate to the home screen.
      Provider.of<UserData>(context, listen: false).loadProfileImage();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
      );
    } catch (e) {
      print("Sign-in failed: $e");
      // Handle authentication errors (e.g., display an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed. Please check your credentials.'),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff009DEA),
        title: const Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(
                image: NetworkImage(
                  "https://dlmrue3jobed1.cloudfront.net/uploads/school/SouthernNewHampshireUniversity/snhu_initials_rgb_pos.png",
                ),
                width: 100,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Welcome to SNHU TutorLink",
                style: TextStyle(fontSize: 16, color: Color(0xff00244E)),
              ),
            ),
            const Align(
              alignment: Alignment.center,

              child: Text(
                "Drop-in sessions are conducted as in-person, group sessions at the designated Peer Educator location",
                style: TextStyle(fontSize: 16, color: Color(0xff00244E)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',

                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: passwordController,

                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _login,
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(const Color(0xff009DEA)),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

