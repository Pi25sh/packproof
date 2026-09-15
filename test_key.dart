import 'package:http/http.dart' as http;

void main() async {
  final key = 'sk-4ee8718729360497-0901c8-247704ef';
  
  // Try OpenAI
  try {
    print('Testing OpenAI...');
    var res = await http.get(
      Uri.parse('https://api.openai.com/v1/models'),
      headers: {'Authorization': 'Bearer ' + key},
    );
    print('OpenAI Status: ' + res.statusCode.toString());
  } catch(e) {}
  
  // Try local omniroute default ports (8000, 8080, 11434, 3000, 4000)
  for (var port in [8000, 8080, 11434, 3000, 4000]) {
    try {
      print('Testing localhost:' + port.toString() + '...');
      var res = await http.get(
        Uri.parse('http://localhost:' + port.toString() + '/v1/models'),
        headers: {'Authorization': 'Bearer ' + key},
      ).timeout(Duration(seconds: 1));
      print('localhost:' + port.toString() + ' Status: ' + res.statusCode.toString());
      if (res.statusCode == 200) print(res.body);
    } catch(e) {}
  }
}
