import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final key = 'sk-4ee8718729360497-0901c8-247704ef';
  final url = Uri.parse('https://api.sambanova.ai/v1/chat/completions');
  
  var res = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + key,
    },
    body: jsonEncode({
      'model': 'Llama-3.2-11B-Vision-Instruct',
      'messages': [
        {
          'role': 'user',
          'content': 'Hi'
        }
      ]
    })
  );
  print('SambaNova Status: ' + res.statusCode.toString());
  print('SambaNova Body: ' + res.body);
}
