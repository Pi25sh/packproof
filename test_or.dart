import 'package:http/http.dart' as http;

void main() async {
  final key = 'sk-4ee8718729360497-0901c8-247704ef';
  final url = 'https://openrouter.ai/api/v1/models';
  
  try {
    var res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer ' + key},
    ).timeout(Duration(seconds: 10));
    print('OpenRouter Status: ' + res.statusCode.toString());
  } catch(e) {
    print('OpenRouter Error: ' + e.toString());
  }
}
