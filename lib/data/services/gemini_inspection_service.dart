import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/config/ai_config.dart';
import '../models/inspection_item.dart';
import '../models/inspection_report.dart';
import '../models/compliance_check.dart';
import '../models/product_details.dart';
import 'inspection_service_interface.dart';
import 'mock_inspection_service.dart';

class GeminiInspectionService implements InspectionServiceInterface {
  static final GeminiInspectionService _instance = GeminiInspectionService._internal();
  factory GeminiInspectionService() => _instance;

  final MockInspectionService _fallbackService = MockInspectionService();

  GeminiInspectionService._internal();

  @override
  Future<List<InspectionItem>> getRecentInspections() async {
    return _fallbackService.getRecentInspections();
  }

  @override
  Future<InspectionReport> analyzePackageLabel({
    String? imagePath,
    Uint8List? imageBytes,
    String? sampleTag,
  }) async {
    // API key check removed to force AI analysis

    if (imageBytes == null) {
      throw Exception('Image bytes are required for AI analysis.');
    }

    try {
      final base64Image = base64Encode(imageBytes);
      String mimeType = 'image/jpeg';
      if (imageBytes.isNotEmpty) {
        if (imageBytes[0] == 0x89) mimeType = 'image/png';
        else if (imageBytes[0] == 0x47) mimeType = 'image/gif';
        else if (imageBytes[0] == 0x52) mimeType = 'image/webp';
      }

      final prompt = '''
You are a strict Legal Metrology Inspector in India. 
Analyze the provided product label image and extract the mandatory declarations under the Packaged Commodities Rules 2011 (PCR 2011).
Verify if the label is compliant with rules like MRP, Net Quantity, Country of Origin, Consumer Care details, etc.
Respond ONLY with a valid JSON object matching the following structure (do not include markdown formatting like ```json):
{
  "businessName": "Name of the shop/store if visible, else 'Unknown Store'",
  "productName": "Extracted Brand or Product Name",
  "netQuantity": "Extracted Net Quantity (e.g. '1 L', '500 g')",
  "mrp": "Extracted MRP (e.g. '₹145.00')",
  "unitSalePrice": "Calculate the USP based on MRP and Net Qty (e.g. '₹0.145 / ml')",
  "mfgDate": "Extracted Manufacturing Date or Batch No",
  "mfgAddress": "Extracted Manufacturer Address",
  "consumerCare": "Extracted Email or Phone for consumer care",
  "countryOfOrigin": "Extracted Country of Origin",
  "overallStatus": "pass" or "violation",
  "statusSummary": "Short uppercase summary (e.g. 'VIOLATION DETECTED')",
  "complianceChecks": [
    {
      "title": "Rule Name (e.g. Mandatory Declarations)",
      "isCompliant": true or false,
      "statusText": "Short status (e.g. Compliant / Non-compliant)",
      "ruleReference": "Rule 6(1), PCR 2011",
      "description": "Explanation of what was found or missing."
    }
  ]
}
Make sure to include at least 3 compliance checks. If MRP or Net Qty is missing, mark as violation.
''';

      final url = Uri.parse(AiConfig.omniRouteBaseUrl);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AiConfig.geminiApiKey}',
        },
        body: jsonEncode({
          'model': AiConfig.omniRouteModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mimeType;base64,$base64Image'
                  }
                }
              ]
            }
          ]
        })
      );

      if (response.statusCode != 200) {
        throw Exception('API Request failed with status \${response.statusCode}: \${response.body}');
      }

      final resData = jsonDecode(response.body);
      String jsonStr = resData['choices'][0]['message']['content'];
      
      // Clean markdown json if any
      jsonStr = jsonStr.trim();
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(jsonStr);
      if (jsonMatch != null) {
        jsonStr = jsonMatch.group(0)!;
      }
      
      if (jsonStr.isEmpty) {
        throw Exception('AI returned empty response');
      }

      final Map<String, dynamic> data = jsonDecode(jsonStr);

      final checks = (data['complianceChecks'] as List).map((check) => ComplianceCheck(
        title: check['title'] ?? 'Check',
        isCompliant: check['isCompliant'] ?? false,
        statusText: check['statusText'] ?? '',
        ruleReference: check['ruleReference'] ?? '',
        description: check['description'] ?? '',
      )).toList();

      final randomId = 'LMD-2026-\${Random().nextInt(9000) + 1000}-\${Random().nextInt(900) + 100}';

      return InspectionReport(
        caseId: randomId,
        officerName: 'Inspector R. Sharma',
        officerId: 'INSP-DL-4082',
        timestamp: DateTime.now(),
        businessName: data['businessName'] ?? 'Unknown Store',
        location: 'Current GPS Location',
        overallStatus: data['overallStatus'] == 'violation' ? InspectionStatus.violation : InspectionStatus.pass,
        statusSummary: data['statusSummary'] ?? (data['overallStatus'] == 'violation' ? 'VIOLATION DETECTED' : 'COMPLIANT / PASS'),
        imagePath: imagePath,
        imageBytes: imageBytes,
        sampleImageTag: sampleTag,
        productDetails: ProductDetails(
          brandName: data['productName'] ?? 'Unknown Product',
          declaredNetQuantity: data['netQuantity'] ?? 'Not found',
          declaredMrp: data['mrp'] ?? 'Not found',
          unitSalePrice: data['unitSalePrice'] ?? 'Not calculated',
          batchMfgDate: data['mfgDate'] ?? 'Not found',
          manufacturerAddress: data['mfgAddress'] ?? 'Not found',
          consumerCareDetails: data['consumerCare'] ?? 'Not found',
          countryOfOrigin: data['countryOfOrigin'] ?? 'Not found',
        ),
        complianceChecks: checks,
      );

    } catch (e) {
      print('AI API Error: $e');
      return InspectionReport(
        caseId: 'ERROR-123',
        officerName: 'System',
        officerId: 'SYS',
        timestamp: DateTime.now(),
        businessName: 'API Error',
        location: 'Local',
        overallStatus: InspectionStatus.violation,
        statusSummary: 'API Error',
        imagePath: imagePath,
        imageBytes: imageBytes,
        sampleImageTag: sampleTag,
        productDetails: ProductDetails(
          brandName: 'Error: $e',
          declaredNetQuantity: '',
          declaredMrp: '',
          unitSalePrice: '',
          batchMfgDate: '',
          manufacturerAddress: '',
          consumerCareDetails: '',
          countryOfOrigin: '',
        ),
        complianceChecks: [],
      );
    }
  }

  @override
  Future<void> saveInspectionToLogs(InspectionReport report) async {
    return _fallbackService.saveInspectionToLogs(report);
  }
}
