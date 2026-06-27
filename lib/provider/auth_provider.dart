import 'package:flutter/material.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  String? _userEmail;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    // Simulate auto-login check latency
    await Future.delayed(const Duration(milliseconds: 1500));
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.trim().isEmpty || !email.contains('@')) {
      _errorMessage = 'Please enter a valid email address.';
      _setLoading(false);
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters.';
      _setLoading(false);
      return false;
    }

    _userEmail = email.trim();
    _status = AuthStatus.authenticated;
    _setLoading(false);
    return true;
  }

  Future<void> continueAsGuest() async {
    _setLoading(true);
    _clearError();

    await Future.delayed(const Duration(milliseconds: 500));

    _userEmail = 'guest@quizmaster.com';
    _status = AuthStatus.authenticated;
    _setLoading(false);
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _userEmail = null;
    _status = AuthStatus.unauthenticated;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
