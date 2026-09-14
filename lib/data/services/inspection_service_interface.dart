import 'dart:typed_data';
import '../models/inspection_item.dart';
import '../models/inspection_report.dart';

/// Contract for the Inspection Service.
/// When integrating with the real AI backend, implement this interface using HTTP / REST.
abstract class InspectionServiceInterface {
  /// Fetches the recent inspections list for the officer.
  Future<List<InspectionItem>> getRecentInspections();

  /// Submits an image for AI analysis and returns the compliance inspection report.
  Future<InspectionReport> analyzePackageLabel({
    String? imagePath,
    Uint8List? imageBytes,
    String? sampleTag,
  });

  /// Saves or exports an inspection memo to local and cloud storage.
  Future<void> saveInspectionToLogs(InspectionReport report);
}
