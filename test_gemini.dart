import 'package:google_generative_ai/google_generative_ai.dart';
import 'lib/core/config/ai_config.dart';

void main() async {
  try {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AiConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
    final prompt = 'Say hello in json';
    final content = [Content.multi([TextPart(prompt)])];
    print('Calling Gemini...');
    final response = await model.generateContent(content);
    print('Response: ' + response.text.toString());
  } catch (e, stacktrace) {
    print('Error: ' + e.toString());
    print('Stacktrace: ' + stacktrace.toString());
  }
}
