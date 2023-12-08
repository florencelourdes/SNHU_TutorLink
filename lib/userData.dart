import 'package:flutter/material.dart';
import 'dart:io';

class UserData extends ChangeNotifier {
  File? _image;
  String? _imageUrl;

  File? get image => _image;
  String? get imageUrl => _imageUrl;

  void setImage(File image, String imageUrl) {
    _image = image;
    _imageUrl = imageUrl;
    notifyListeners();
  }
}
