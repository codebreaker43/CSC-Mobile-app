import 'package:flutter/foundation.dart';

class UserProfileData {
  static final UserProfileData _instance = UserProfileData._internal();

  factory UserProfileData() {
    return _instance;
  }

  UserProfileData._internal();

  String name = "User Name";
  String email = "user@example.com";
  String? imagePath;

  final ValueNotifier<int> _notifier = ValueNotifier(0);

  ValueListenable<int> get notifier => _notifier;

  void updateProfile({String? newName, String? newEmail, String? newImagePath}) {
    if (newName != null) name = newName;
    if (newEmail != null) email = newEmail;
    if (newImagePath != null) imagePath = newImagePath;
    _notifier.value++; // Notify listeners
  }
}
