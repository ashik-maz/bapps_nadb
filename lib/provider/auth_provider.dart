import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bdapps_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final BDappsService _bdapps = BDappsService();

  User? _user;
  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;
  bool _isLoading = false;
  String? _userMobile;
  String? _userName;
  bool _isSubscribed = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get userEmail => _user?.email;
  String? get userMobile => _userMobile;
  String? get userName => _userName ?? _user?.displayName ?? 'Learner';
  bool get isSubscribed => _isSubscribed;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _initPersistentSession();
  }

  /// Initialize persistent session: auto-logins saved mobile number
  /// and automatically restores subscription status
  Future<void> _initPersistentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMobile = prefs.getString('user_mobile');
      final savedName = prefs.getString('user_name');
      final savedIsSubscribed = prefs.getBool('is_subscribed') ?? false;

      if (savedName != null && savedName.isNotEmpty) {
        _userName = savedName;
      }

      if (savedMobile != null && savedMobile.isNotEmpty) {
        _userMobile = savedMobile;
        _isSubscribed = savedIsSubscribed;
        _userName ??= 'Learner (${savedMobile.substring(0, 5)}***)';
        _status = AuthStatus.authenticated;
        notifyListeners();

        // Background check for subscription status against BDapps live API
        await checkSubscriptionInBackground();
        return;
      }
    } catch (_) {}

    _user = _auth.currentUser;
    if (_user != null) {
      _status = AuthStatus.authenticated;
      _userName = _user!.displayName;
      _fetchUserProfile(_user!.uid);
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  /// Re-check subscription live in background
  Future<bool> checkSubscriptionInBackground() async {
    if (_userMobile == null || _userMobile!.isEmpty) {
      if (_isSubscribed) {
        _isSubscribed = false;
        notifyListeners();
      }
      return false;
    }
    try {
      final isSub = await _bdapps.checkSubscription(_userMobile!);
      if (isSub) {
        setSubscriptionState(true, mobile: _userMobile);
      }
      return _isSubscribed;
    } catch (_) {
      return _isSubscribed;
    }
  }

  void setSubscriptionState(bool isSub, {String? mobile}) async {
    _isSubscribed = isSub;
    if (mobile != null && mobile.isNotEmpty) {
      _userMobile = mobile;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_subscribed', isSub);
      if (mobile != null && mobile.isNotEmpty) {
        await prefs.setString('user_mobile', mobile);
      }
    } catch (_) {}
  }

  void setUserName(String newName) async {
    _userName = newName;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newName);
      if (_userMobile != null && _userMobile!.isNotEmpty) {
        _db.collection('users').doc(_userMobile).set({'name': newName}, SetOptions(merge: true));
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        _userName = data?['name'] ?? _userName;
        _userMobile = data?['mobile'];
        if (_userMobile != null && _userMobile!.isNotEmpty) {
          _isSubscribed = await _bdapps.checkSubscription(_userMobile!);
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Direct mobile verification without Firebase login/signup complexity
  Future<bool> loginWithMobileDirect(String rawMobile, {bool? forceSubscribed}) async {
    _setLoading(true);
    _clearError();
    try {
      String cleanDigits = rawMobile.replaceAll(RegExp(r'\D+'), '');
      if (cleanDigits.startsWith('880') && cleanDigits.length == 13) {
        cleanDigits = cleanDigits.substring(2);
      } else if (cleanDigits.length == 10 && cleanDigits.startsWith('1')) {
        cleanDigits = '0$cleanDigits';
      }

      if (cleanDigits.length < 11) {
        _errorMessage = 'Please enter a valid 11-digit mobile number';
        _setLoading(false);
        return false;
      }

      // Query BDapps backend directly for live subscription status if forceSubscribed not provided
      if (forceSubscribed != null) {
        _isSubscribed = forceSubscribed;
      } else {
        _isSubscribed = await _bdapps.checkSubscription(cleanDigits);
      }
      _userMobile = cleanDigits;
      _userName ??= 'Learner (${cleanDigits.substring(0, 5)}***)';
      _status = AuthStatus.authenticated;

      // Save to SharedPreferences for persistent auto-login
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_mobile', cleanDigits);
        if (_userName != null) await prefs.setString('user_name', _userName!);
      } catch (_) {}

      // Save/update user profile in Firestore
      try {
        final doc = await _db.collection('users').doc(cleanDigits).get();
        if (doc.exists && doc.data()?['name'] != null) {
          _userName = doc.data()!['name'];
        } else {
          await _db.collection('users').doc(cleanDigits).set({
            'mobile': cleanDigits,
            'name': _userName,
            'isSubscribed': _isSubscribed,
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (_) {}

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Mobile verification failed. Check connection.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_mobile');
      await prefs.remove('user_name');
      await _auth.signOut();
    } catch (_) {}
    _user = null;
    _userMobile = null;
    _userName = null;
    _isSubscribed = false;
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
