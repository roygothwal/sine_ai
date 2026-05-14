import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Vercel API URL ✅
  static const String _backendUrl =
      'https://sine-95nv5yjof-suryaroy1008-4764s-projects.vercel.app/api/chat';

  static List<Map<String, dynamic>> _history = [];

  static Future<String> sendMessage(String userMessage) async {
    try {
      _history.add({
        'role': 'user',
        'parts': [
          {'text': userMessage}
        ]
      });

      final response = await http
          .post(
            Uri.parse(_backendUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': userMessage,
              'history': _history.take(10).toList(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] as String;

        _history.add({
          'role': 'model',
          'parts': [
            {'text': reply}
          ]
        });

        if (_history.length > 20) {
          _history.removeRange(0, 2);
        }

        return reply;
      } else {
        return 'Yaar kuch problem ho gayi! 😅';
      }
    } catch (e) {
      return 'Internet check kar bhai! 🔌';
    }
  }

  static void clearHistory() => _history = [];
}
