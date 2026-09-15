import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final ports = [5040, 9080, 10007, 15292, 15393, 16494, 20131, 20132, 31416, 31417, 31422, 31423, 43809, 44456, 50764, 50766, 50767, 50777, 64996, 64997];
  for (var port in ports) {
    try {
      var res = await http.post(
        Uri.parse('http://localhost:' + port.toString() + '/v1/chat/completions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"model": "test", "messages": []})
      ).timeout(Duration(milliseconds: 500));
      print('Port ' + port.toString() + ' -> ' + res.statusCode.toString());
    } catch(e) {
    }
  }
}
