import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final ports = [9080, 31416, 31422, 44456, 50764, 50766, 50767, 50777, 64996, 64997];
  for (var port in ports) {
    try {
      print('Testing port ' + port.toString());
      var res = await http.get(Uri.parse('http://localhost:' + port.toString() + '/v1/models')).timeout(Duration(milliseconds: 500));
      print('Port ' + port.toString() + ' -> ' + res.statusCode.toString());
    } catch(e) {
      print('Port ' + port.toString() + ' -> Error');
    }
  }
}
