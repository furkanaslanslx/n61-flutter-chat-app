import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/shared_preferences_service.dart';

class UserViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;
  List<Map<String, dynamic>> _usersList = [];

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;
  List<Map<String, dynamic>> get usersList => _usersList;
  String? get userName => _currentUser?['userName'];
  String? get userPhone => _currentUser?['phoneNumber'];
  String? get userAddress => _currentUser?['address'];

  UserViewModel() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await _checkLoginStatus();
    await _loadUsersList();
  }

  Future<void> _checkLoginStatus() async {
    try {
      _isLoggedIn = await SharedPreferencesService.isLoggedIn();
      if (_isLoggedIn) {
        _currentUser = await SharedPreferencesService.getCurrentUser();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Login status check error: $e');
    }
  }

  Future<void> _loadUsersList() async {
    try {
      _usersList = await SharedPreferencesService.getUsersList();
      notifyListeners();
    } catch (e) {
      debugPrint('Load users list error: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      bool success = await SharedPreferencesService.login(email, password);
      if (success) {
        await _checkLoginStatus();
        await _loadUsersList();
      }
      return success;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String userName,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      bool success = await SharedPreferencesService.registerUser(
        email: email,
        userName: userName,
        password: password,
        phoneNumber: phoneNumber,
        address: address,
      );
      if (success) {
        await _checkLoginStatus();
        await _loadUsersList();
      }
      return success;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await SharedPreferencesService.logout();
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<bool> deleteAccount() async {
    try {
      if (_currentUser != null) {
        bool success = await SharedPreferencesService.deleteUser(_currentUser!['email']);
        if (success) {
          _isLoggedIn = false;
          _currentUser = null;
          await _loadUsersList();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Delete account error: $e');
      return false;
    }
  }

  Future<bool> updateUserProfile({
    required String userName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      if (_currentUser != null) {
        Map<String, dynamic> updatedUser = {..._currentUser!};
        updatedUser['userName'] = userName;
        updatedUser['phoneNumber'] = phoneNumber;
        updatedUser['address'] = address;

        bool success = await SharedPreferencesService.updateUser(updatedUser);
        if (success) {
          _currentUser = updatedUser;
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    }
  }
}
