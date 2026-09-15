import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = Uri.parse('http://localhost:20128/v1/models');
  var res = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer sk-4ee8718729360497-0901c8-247704ef',
    },
  );
  var data = jsonDecode(res.body);
  var models = data['data'] as List;
  var textModels = models.where((m) => m['output_modalities'] != null && m['output_modalities'].contains('text')).toList();
  for (var m in textModels) {
    if (m['id'].toString().toLowerCase().contains('gemini')) {
      print('FOUND GEMINI: ' + m['id']);
    }
  }
  print('Total text models: ' + textModels.length.toString());
  if (textModels.length > 0) {
    print('Sample text model: ' + textModels[0]['id']);
    print('Sample 2: ' + textModels[1]['id']);
    print('Sample 3: ' + textModels[2]['id']);
  }
}
