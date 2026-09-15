import 'dart:typed_data';
import '../models/inspection_item.dart';
import '../models/inspection_report.dart';
import '../models/compliance_check.dart';
import '../models/product_details.dart';
import 'inspection_service_interface.dart';

/// Mock implementation of [InspectionServiceInterface].
///
/// Ready for backend integration:
/// To connect to your real REST API:
/// 1. Replace the mock delay with an `http.MultipartRequest('POST', Uri.parse('$baseUrl/api/v1/analyze'))`
/// 2. Stream the image bytes or file to your ML model endpoint
/// 3. Parse JSON response into [InspectionReport.fromJson]
class MockInspectionService implements InspectionServiceInterface {
  // Singleton pattern for consistent in-memory state during the session
  static final MockInspectionService _instance = MockInspectionService._internal();
  factory MockInspectionService() => _instance;

  final List<InspectionItem> _recentInspections = [];

  MockInspectionService._internal() {
    _seedInitialMockData();
  }

  void _seedInitialMockData() {
    // Empty: no fake initial data.
  }

  @override
  Future<List<InspectionItem>> getRecentInspections() async {
    // Simulate brief local/network latency
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_recentInspections);
  }

  @override
  Future<InspectionReport> analyzePackageLabel({
    String? imagePath,
    Uint8List? imageBytes,
    String? sampleTag,
  }) async {
    // Realistic AI inference latency (2 seconds) as requested
    await Future.delayed(const Duration(seconds: 2));

    // Return the detailed mock report for toothpaste
    return InspectionReport.mockToothpasteViolation(
      imagePath: imagePath,
      imageBytes: imageBytes,
      sampleTag: sampleTag,
    );
  }

  @override
  Future<void> saveInspectionToLogs(InspectionReport report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newItem = InspectionItem.fromReport(report);
    // Remove if already exists with same case ID
    _recentInspections.removeWhere((i) => i.id == newItem.id);
    // Add to top of recent inspections list
    _recentInspections.insert(0, newItem);
  }
}
