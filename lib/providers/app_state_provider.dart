import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider with ChangeNotifier {
  bool _showTour = false;
  bool _tourCompleted = false;
  bool _isDarkMode = false;

  bool get showTour => _showTour;
  bool get tourCompleted => _tourCompleted;
  bool get isDarkMode => _isDarkMode;

  AppStateProvider() {
    _checkTourStatus();
    _loadThemePreference();
  }

  Future<void> _checkTourStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _tourCompleted = prefs.getBool('tour_completed') ?? false;

    // If tour is not completed, we might want to start it automatically or wait for a user trigger
    // For now, let's just expose the state.
    // Usually, we'd trigger it on the first screen load if !_tourCompleted.
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    debugPrint('🌙 Dark mode toggled: $_isDarkMode');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    debugPrint('💾 Dark mode saved to preferences: $_isDarkMode');
  }

  void startTour() {
    _showTour = true;
    notifyListeners();
  }

  void endTour() {
    _showTour = false;
    notifyListeners();
  }

  Future<void> completeTour() async {
    _showTour = false;
    _tourCompleted = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tour_completed', true);
  }

  // Debug method to reset tour
  Future<void> resetTour() async {
    _tourCompleted = false;
    _showTour = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tour_completed');
  }
}
