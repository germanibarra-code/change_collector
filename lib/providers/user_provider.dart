import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProvider with ChangeNotifier {
  UserProfile _userProfile = UserProfile(
    name: 'Usuario',
    email: 'usuario@ejemplo.com',
    avatarIndex: 0,
  );
  bool _isLoading = true;

  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  UserProvider() {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userStr = prefs.getString('user_profile');

    if (userStr != null) {
      _userProfile = UserProfile.fromMap(json.decode(userStr));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserProfile(
    String name,
    String email,
    int avatarIndex,
  ) async {
    _userProfile = UserProfile(
      name: name,
      email: email,
      avatarIndex: avatarIndex,
    );
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(_userProfile.toMap()));
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    _userProfile = UserProfile(
      name: 'Usuario',
      email: 'usuario@ejemplo.com',
      avatarIndex: 0,
    );
    notifyListeners();
  }
}
