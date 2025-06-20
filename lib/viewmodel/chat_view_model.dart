import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_api.dart';
import 'dart:convert';

class ChatViewModel extends ChangeNotifier {
  final ChatApi _api = ChatApi();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isApiConnected = false;
  bool _disposed = false;
  final TextEditingController messageController = TextEditingController();

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isApiConnected => _isApiConnected;

  ChatViewModel() {
    _loadMessages();
    _checkApiConnection();
  }

  Future<void> _checkApiConnection() async {
    _isApiConnected = await _api.ping();
    if (_disposed) return; // ViewMolel dispose edilmişse çık
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Kullanıcı mesajını ekle
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    if (!_disposed) notifyListeners();

    try {
      // Yeni API'yi kullan
      final answer = await _api.sendMessage(text);
      final botMessage = ChatMessage(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
        type: 'kb+llm',
      );
      _messages.add(botMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        text: "⚠️ Bağlantı hatası: $e",
        isUser: false,
        timestamp: DateTime.now(),
        type: 'error',
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }

    // Mesajları kaydet
    _saveMessages();

    // Text controller'ı temizle
    messageController.clear();
  }

  void clearMessages() {
    _messages.clear();
    _saveMessages();
    if (!_disposed) notifyListeners();
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages.map((m) => m.toJson()).toList();
      await prefs.setString('chat_messages', jsonEncode(messagesJson));
    } catch (e) {
      print('Mesajları kaydetme hatası: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString('chat_messages');
      if (messagesString != null) {
        final List<dynamic> messagesJson = jsonDecode(messagesString);
        _messages = messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
        if (!_disposed) notifyListeners();
      }
    } catch (e) {
      print('Mesajları yükleme hatası: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    messageController.dispose();
    super.dispose();
  }
}
