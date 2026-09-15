import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/core/config/ai_config.dart';

void main() async {
  print('Testing Groq API integration...');
  print('Using Model: ${AiConfig.omniRouteModel}');
  print('Using Endpoint: ${AiConfig.omniRouteBaseUrl}');
  
  // Fetch a real image to test with
  final imgRes = await http.get(Uri.parse('https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/React-icon.svg/128px-React-icon.svg.png'));
  final base64Image = base64Encode(imgRes.bodyBytes);
  
  final url = Uri.parse(AiConfig.omniRouteBaseUrl);
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AiConfig.geminiApiKey}',
      },
      body: jsonEncode({
        'model': AiConfig.omniRouteModel,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': 'Describe this image'},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
                }
              }
            ]
          }
        ]
      }),
    );
    
    if (response.statusCode == 200) {
      final resData = jsonDecode(response.body);
      final reply = resData['choices'][0]['message']['content'];
      print('\nSuccess! Response from Groq:');
      print('-----------------------------');
      print(reply);
      print('-----------------------------');
    } else {
      print('\nError: Request failed with status ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }
}
