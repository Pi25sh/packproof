import 'package:google_generative_ai/google_generative_ai.dart';
import 'lib/core/config/ai_config.dart';

void main() async {
  print('Key: ' + AiConfig.geminiApiKey);
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: AiConfig.geminiApiKey,
  );
  try {
    final prompt = 'Hi';
    final content = [Content.multi([TextPart(prompt)])];
    final response = await model.generateContent(content);
    print('Success: ' + response.text.toString());
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
