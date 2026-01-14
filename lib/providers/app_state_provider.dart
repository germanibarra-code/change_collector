import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider with ChangeNotifier {
  bool _showTour = false;
  bool _tourCompleted = false;

  bool get showTour => _showTour;
  bool get tourCompleted => _tourCompleted;

  AppStateProvider() {
    _checkTourStatus();
  }

  Future<void> _checkTourStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _tourCompleted = prefs.getBool('tour_completed') ?? false;

    // If tour is not completed, we might want to start it automatically or wait for a user trigger
    // For now, let's just expose the state.
    // Usually, we'd trigger it on the first screen load if !_tourCompleted.
    notifyListeners();
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
