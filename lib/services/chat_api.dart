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
      return "http://10.0.2.2:8000"; // Android emulator için
    } else if (Platform.isIOS) {
      return "http://localhost:8000"; // iOS Simulator için
    } else {
      return "http://localhost:8000"; // Masaüstü için
    }
  }

  static const _timeout = Duration(seconds: 60);

  Future<bool> ping() async {
    try {
      final res = await http.get(
        Uri.parse("$_baseUrl/health"),
        headers: {
          "Accept": "application/json; charset=utf-8",
        },
      ).timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      print('API ping hatası: $e');
      return false;
    }
  }

  Future<String> sendMessage(String message, {String? sessionId, List<ChatMessage>? history}) async {
    final uri = Uri.parse("$_baseUrl/chat");

    // Chat history'yi API formatına çevir
    List<Map<String, String>>? apiHistory;
    if (history != null) {
      apiHistory = history
          .map((msg) => {
                "role": msg.isUser ? "user" : "assistant",
                "content": msg.text,
              })
          .toList();
    }

    final body = jsonEncode({
      "message": message,
      if (sessionId != null) "session_id": sessionId,
      if (apiHistory != null) "history": apiHistory,
    });

    final res = await http
        .post(
          uri,
          headers: {
            "Content-Type": "application/json; charset=utf-8",
            "Accept": "application/json; charset=utf-8",
          },
          body: body,
        )
        .timeout(_timeout);

    if (res.statusCode == 200) {
      // UTF-8 encoding sorununu çöz
      final responseBody = utf8.decode(res.bodyBytes);
      final decodedResponse = jsonDecode(responseBody);
      return decodedResponse['answer'];
    } else {
      throw Exception("API error: ${res.body}");
    }
  }
}
