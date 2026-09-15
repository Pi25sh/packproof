import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lib/core/config/ai_config.dart';

void main() async {
  final key = AiConfig.geminiApiKey;
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent');
  
  var res3 = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + key
    },
    body: jsonEncode({
      'contents': [{'parts': [{'text': 'Hi'}]}]
    })
  );
  print('3 Status: ' + res3.statusCode.toString());
  print('3 Body: ' + res3.body);
}
