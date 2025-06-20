import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _currentUserKey = 'currentUser';
  static const String _usersListKey = 'usersList';

  // Kullanıcı modeli
  static Map<String, dynamic> createUserMap({
    required String email,
    required String userName,
    required String password,
    String? phoneNumber,
    String? address,
  }) {
    return {
      'email': email,
      'userName': userName,
      'password': password,
      'phoneNumber': phoneNumber ?? '',
      'address': address ?? '',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Kullanıcı listesini getir
  static Future<List<Map<String, dynamic>>> getUsersList() async {
    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString(_usersListKey);
    if (usersJson == null) return [];

    List<dynamic> usersList = json.decode(usersJson);
    return usersList.cast<Map<String, dynamic>>();
  }

  // Kullanıcı listesini kaydet
  static Future<void> saveUsersList(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    String usersJson = json.encode(users);
    await prefs.setString(_usersListKey, usersJson);
  }

  // Yeni kullanıcı kaydet
  static Future<bool> registerUser({
    required String email,
    required String userName,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      final usersList = await getUsersList();

      // E-posta kontrolü
      if (usersList.any((user) => user['email'] == email)) {
        return false;
      }

      final newUser = {
        'email': email,
        'userName': userName,
        'password': password,
        'phoneNumber': phoneNumber,
        'address': address,
        'createdAt': DateTime.now().toIso8601String(),
      };

      usersList.add(newUser);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('users', jsonEncode(usersList));
      await prefs.setString('currentUser', jsonEncode(newUser));
      await prefs.setBool('isLoggedIn', true);

      return true;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  // Giriş kontrolü
  static Future<bool> login(String email, String password) async {
    try {
      List<Map<String, dynamic>> users = await getUsersList();

      // Kullanıcıyı bul
      Map<String, dynamic>? user = users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        return false;
      }

      // Kullanıcıyı aktif et
      await setCurrentUser(user);
      return true;
    } catch (e) {
      print('Giriş hatası: $e');
      return false;
    }
  }

  // Aktif kullanıcıyı ayarla
  static Future<void> setCurrentUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_currentUserKey, json.encode(user));
  }

  // Aktif kullanıcı bilgilerini getir
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    return json.decode(userJson);
  }

  // Kullanıcı sil
  static Future<bool> deleteUser(String email) async {
    try {
      List<Map<String, dynamic>> users = await getUsersList();
      users.removeWhere((user) => user['email'] == email);
      await saveUsersList(users);

      // Eğer silinen kullanıcı aktif kullanıcı ise çıkış yap
      Map<String, dynamic>? currentUser = await getCurrentUser();
      if (currentUser != null && currentUser['email'] == email) {
        await logout();
      }

      return true;
    } catch (e) {
      print('Kullanıcı silme hatası: $e');
      return false;
    }
  }

  // Çıkış yap
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_currentUserKey);
  }

  // Giriş durumunu kontrol et
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Kullanıcı güncelleme fonksiyonu ekle
  static Future<bool> updateUser(Map<String, dynamic> updatedUser) async {
    try {
      List<Map<String, dynamic>> users = await getUsersList();
      int userIndex = users.indexWhere((user) => user['email'] == updatedUser['email']);

      if (userIndex != -1) {
        updatedUser['updatedAt'] = DateTime.now().toIso8601String();
        users[userIndex] = updatedUser;
        await saveUsersList(users);
        await setCurrentUser(updatedUser);
        return true;
      }
      return false;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }
}
