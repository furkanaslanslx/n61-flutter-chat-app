// lib/services/chat_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:n61/m/product_model.dart';

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

class PageContext {
  final String pageType; // "home", "product_detail", "category", etc.
  final String? pageTitle;
  final List<Product>? currentProducts; // Anasayfadaki ürünler
  final Product? currentProduct; // Detay sayfasındaki ürün
  final Map<String, dynamic>? additionalInfo; // Ek bilgiler

  PageContext({
    required this.pageType,
    this.pageTitle,
    this.currentProducts,
    this.currentProduct,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'page_type': pageType,
      'page_title': pageTitle,
      'current_products': currentProducts?.map((p) => p.toJson()).toList(),
      'current_product': currentProduct?.toJson(),
      'additional_info': additionalInfo,
    };
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
      final res = await http.get(
        Uri.parse("$_baseUrl/health"),
        headers: {
          "Accept": "application/json; charset=utf-8",
        },
      ).timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('API ping hatası: $e');
      return false;
    }
  }

  Future<String> sendMessage(
    String message, {
    String? sessionId,
    List<ChatMessage>? history,
    PageContext? pageContext,
  }) async {
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
      if (pageContext != null) "page_context": pageContext.toJson(),
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
