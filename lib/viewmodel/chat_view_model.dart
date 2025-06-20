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
  String? _sessionId;
  final TextEditingController messageController = TextEditingController();

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isApiConnected => _isApiConnected;

  ChatViewModel() {
    _loadMessages();
    _loadSessionId();
    _checkApiConnection();
  }

  Future<void> _checkApiConnection() async {
    _isApiConnected = await _api.ping();
    if (_disposed) return; // ViewMolel dispose edilmişse çık
    notifyListeners();
  }

  Future<void> _loadSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString('session_id');
      if (_sessionId == null) {
        // Yeni session ID oluştur
        _sessionId = 'user-${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('session_id', _sessionId!);
      }
    } catch (e) {
      print('Session ID yükleme hatası: $e');
      _sessionId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    }
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
      // Session ID ve chat history ile API'yi çağır
      final answer = await _api.sendMessage(
        text,
        sessionId: _sessionId,
        history: _messages.where((msg) => msg.type != 'error').toList(), // Error mesajları hariç
      );

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
    // Yeni session başlat
    _sessionId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    _saveSessionId();
    if (!_disposed) notifyListeners();
  }

  Future<void> _saveSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_sessionId != null) {
        await prefs.setString('session_id', _sessionId!);
      }
    } catch (e) {
      print('Session ID kaydetme hatası: $e');
    }
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
