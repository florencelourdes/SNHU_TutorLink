import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class UserData extends ChangeNotifier {
  File? _image;
  String? _imageUrl;

  File? get image => _image;
  String? get imageUrl => _imageUrl;

  Future<void> loadProfileImage() async{
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      final destination = 'public/images/${auth.currentUser?.uid ?? ""}';

      final ref = FirebaseStorage.instance
          .ref()
          .child(destination);
      _imageUrl = await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}': ${e.message}");
    }

    if(_imageUrl != null){
      Image image = Image.network(_imageUrl ?? "");
    }else{
      _imageUrl = "...";
    }

    notifyListeners();
  }

  Future<void> setImage(File image, String imageUrl) async {
    _image = image;
    _imageUrl = imageUrl;

    notifyListeners();
  }



}
