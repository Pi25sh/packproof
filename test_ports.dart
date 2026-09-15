import 'package:http/http.dart' as http;

void main() async {
  final ports = [9080, 31416, 31422, 44456, 50764, 50766, 50767, 50777, 64996, 64997, 8000, 8081, 11434, 3000, 3001];
  
  for (var port in ports) {
    try {
      var res = await http.get(
        Uri.parse('http://localhost:' + port.toString() + '/v1/models'),
      ).timeout(Duration(milliseconds: 500));
      print('Port ' + port.toString() + ' responded with: ' + res.statusCode.toString());
    } catch(e) {}
  }
}
