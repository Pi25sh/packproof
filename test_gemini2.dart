import 'package:google_generative_ai/google_generative_ai.dart';
import 'lib/core/config/ai_config.dart';

void main() async {
  for (var modelName in ['gemini-1.5-flash-latest', 'gemini-1.5-pro', 'gemini-pro-vision', 'gemini-pro']) {
    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: AiConfig.geminiApiKey,
      );
      final prompt = 'Say hello';
      final content = [Content.multi([TextPart(prompt)])];
      print('Testing \$modelName...');
      final response = await model.generateContent(content);
      print('Success for \$modelName: \${response.text}');
      break;
    } catch (e) {
      print('Failed for \$modelName: \$e');
    }
  }
}
