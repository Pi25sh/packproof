import 'package:http/http.dart' as http;

void main() async {
  final key = 'sk-4ee8718729360497-0901c8-247704ef';
  final urls = [
    'https://openrouter.ai/api/v1/models',
    'https://api.together.xyz/v1/models',
    'https://api.deepseek.com/v1/models',
    'https://api.groq.com/openai/v1/models',
    'https://api.sambanova.ai/v1/models',
    'https://api.fireworks.ai/inference/v1/models',
    'https://api.moonshot.cn/v1/models',
    'https://dashscope.aliyuncs.com/compatible-mode/v1/models',
    'https://api.siliconflow.cn/v1/models',
  ];
  
  for (var url in urls) {
    try {
      var res = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ' + key},
      ).timeout(Duration(seconds: 2));
      print(url + ' -> ' + res.statusCode.toString());
    } catch(e) {
      print(url + ' -> Error');
    }
  }
}
