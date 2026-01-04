import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'language_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class ChatbotService extends ChangeNotifier {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  // Groq API - Set your API key here or use environment variable
  // Get your free API key from: https://console.groq.com/keys
  static const String _apiKey = 'YOUR_GROQ_API_KEY'; // Replace with your key
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  String _getSystemPrompt(String langCode) {
    final langName = langCode == 'hi' ? 'Hindi' : langCode == 'mr' ? 'Marathi' : 'English';
    return '''You are InvestSathi AI, a friendly financial assistant for Indian users learning about investments.
Your role:
- Help users understand investing, mutual funds, SIPs, stocks, and financial planning
- Give simple, easy-to-understand explanations suitable for beginners
- Use relatable Indian examples (chai, thali, festivals) when explaining concepts
- Be encouraging and supportive
- Keep responses concise (2-3 sentences for simple questions)
- ALWAYS respond in $langName language only
- Use ₹ for currency
- If asked about specific stock tips or guaranteed returns, politely explain you can't give specific advice

Current language: $langName. You MUST respond in $langName only.''';
  }

  Future<String> sendMessage(String userMessage, LanguageService langService) async {
    if (userMessage.trim().isEmpty) return '';

    _messages.add(ChatMessage(text: userMessage, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _callGroqApi(userMessage, langService.langCode);
      _messages.add(ChatMessage(text: response, isUser: false));
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      debugPrint('Chatbot Error: $e');
      final errorMsg = langService.langCode == 'hi'
          ? 'माफ़ कीजिए, कुछ गड़बड़ हो गई। कृपया फिर से कोशिश करें।'
          : langService.langCode == 'mr'
              ? 'माफ करा, काहीतरी चूक झाली. कृपया पुन्हा प्रयत्न करा.'
              : 'Sorry, something went wrong. Please try again.';
      _messages.add(ChatMessage(text: errorMsg, isUser: false));
      _isLoading = false;
      notifyListeners();
      return errorMsg;
    }
  }

  Future<String> _callGroqApi(String message, String langCode) async {
    final url = Uri.parse(_baseUrl);

    final body = jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'system', 'content': _getSystemPrompt(langCode)},
        {'role': 'user', 'content': message}
      ],
      'max_tokens': 500,
      'temperature': 0.7,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['choices']?[0]?['message']?['content'] ?? '';
      return text.trim();
    } else {
      debugPrint('Groq API Error: ${response.statusCode} - ${response.body}');
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
