import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('http://localhost:20128/v1/models');
  try {
    var res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer sk-4ee8718729360497-0901c8-247704ef',
      },
    ).timeout(Duration(seconds: 3));
    print('Status: ' + res.statusCode.toString());
    print('Body: ' + res.body);
  } catch(e) {
    print('Error: ' + e.toString());
  }
}
