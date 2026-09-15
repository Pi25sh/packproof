import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lib/core/config/ai_config.dart';

void main() async {
  final url = Uri.parse('http://localhost:20128/v1/chat/completions');
  try {
    var res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + AiConfig.geminiApiKey,
      },
      body: jsonEncode({
        'model': AiConfig.omniRouteModel,
        'messages': [
          {'role': 'user', 'content': 'hello'}
        ]
      })
    ).timeout(Duration(seconds: 3));
    print('Status: ' + res.statusCode.toString());
    print('Body: ' + res.body);
  } catch(e) {
    print('Error: ' + e.toString());
  }
}
