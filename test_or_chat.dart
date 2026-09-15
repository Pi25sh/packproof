import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lib/core/config/ai_config.dart';

void main() async {
  final key = AiConfig.geminiApiKey;
  print('Key is: ' + key);
  final url = Uri.parse(AiConfig.openRouterBaseUrl);
  
  var res = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + key,
    },
    body: jsonEncode({
      'model': AiConfig.openRouterModel,
      'messages': [
        {
          'role': 'user',
          'content': 'Hi'
        }
      ]
    })
  );
  print('OpenRouter Status: ' + res.statusCode.toString());
  print('OpenRouter Body: ' + res.body);
}
