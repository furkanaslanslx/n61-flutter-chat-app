// lib/services/chat_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? type;
  final String? context;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'context': context,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      context: json['context'],
    );
  }
}

class ChatApi {
  // Platform'a göre dinamik URL belirleme
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return "http://192.168.1.18:8000"; // Android emulator için
    } else if (Platform.isIOS) {
      return "http://192.168.1.18:8000"; // iOS Simulator için
    } else {
      return "http://192.168.1.18:8000"; // Masaüstü için
    }
  }

  static const _timeout = Duration(seconds: 60);

  Future<bool> ping() async {
    try {
      final res = await http.get(Uri.parse("$_baseUrl/health")).timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      print('API ping hatası: $e');
      return false;
    }
  }

  Future<String> sendMessage(String message) async {
    final uri = Uri.parse("$_baseUrl/chat");
    final body = jsonEncode({"message": message});
    final res = await http.post(uri, headers: {"Content-Type": "application/json"}, body: body).timeout(_timeout);

    if (res.statusCode == 200) {
      return jsonDecode(res.body)['answer'];
    } else {
      throw Exception("API error: ${res.body}");
    }
  }
}
