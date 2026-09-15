import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'lib/core/config/ai_config.dart';

class ProxyClient extends http.BaseClient {
  final String proxyUrl;
  final http.Client _inner = http.Client();

  ProxyClient(this.proxyUrl);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Rewrite URL to proxyUrl
    // ...
    return _inner.send(request);
  }
}
