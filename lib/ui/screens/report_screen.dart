import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/inspection_report.dart';
import '../../data/models/compliance_check.dart';
import '../../data/services/mock_inspection_service.dart';
import '../../data/services/pdf_report_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/package_canvas_widget.dart';

/// Screen 4: Inspection Report Screen
/// High-contrast, card-based official inspection memo detailing extracted package attributes,
/// rule compliance checklist, case metadata, and export/save actions.
class ReportScreen extends StatefulWidget {
  final InspectionReport report;
  final bool isSavedRecord;

  const ReportScreen({
    super.key,
    required this.report,
    this.isSavedRecord = false,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _service = MockInspectionService();
  bool _isSaving = false;

  void _handleSaveToLogs() async {
    setState(() => _isSaving = true);
    String savedPdfPath = '';
    try {
      // 1. Generate and save the official PDF file to device storage
      savedPdfPath = await PdfReportService.savePdfToFile(widget.report);
    } catch (_) {}

    // 2. Save the inspection report with PDF path attached into case logs
    final updatedReport = widget.report.copyWith(pdfPath: savedPdfPath);
    await _service.saveInspectionToLogs(updatedReport);
    if (!mounted) return;

    // 3. Show high-contrast confirmation SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Case #${widget.report.caseId} saved to Case Logs in PDF form.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate back to Home with true to indicate record was saved
    Navigator.of(context).pop(true);
  }

  void _handlePrintSharePdf() async {
    try {
      // Save PDF file to storage
      final path = await PdfReportService.savePdfToFile(widget.report);
      // Trigger native print / PDF share dialog
      await PdfReportService.printOrSharePdf(widget.report);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Form II PDF memo generated & saved to files: ${path.split('/').last}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryNavy,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not print/save PDF: $e'),
            backgroundColor: AppTheme.violationRed,
          ),
        );
      }
    }
  }

  void _showImageZoomDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: PackageCanvasWidget(
                imagePath: widget.report.imagePath,
                imageBytes: widget.report.imageBytes,
                sampleTag: widget.report.sampleImageTag,
                height: 480,
                showBoundingBoxes: false,
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(16),
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Inspection Memo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white),
            tooltip: 'Print Memo',
            onPressed: _handlePrintSharePdf,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Status Banner at Top (High-contrast red or green)
                StatusBadge(
                  status: report.overallStatus,
                  isLargeBanner: true,
                  customLabel: report.statusSummary,
                ),
                const SizedBox(height: 20),

                // 2. Summary Card: Case ID, Timestamp, Officer Name, Thumbnail
                _buildSummaryCard(report),
                const SizedBox(height: 18),

                // 3. Extracted Product Details (mocked)
                _buildExtractedDetailsCard(report),
                const SizedBox(height: 18),

                // 4. Compliance Checklist Card
                _buildComplianceChecklistCard(report),
                const SizedBox(height: 28),

                // 5. Action Buttons at Bottom
                _buildBottomActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Summary Card: Case ID, Timestamp, Officer Name + Image Thumbnail
  Widget _buildSummaryCard(InspectionReport report) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Case Metadata',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.caseId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryNavy,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppTheme.borderLight),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Column
                Expanded(
                  child: Column(
                    children: [
                      _buildMetaRow(Icons.person_pin_rounded, 'Officer', report.officerName),
                      const SizedBox(height: 10),
                      _buildMetaRow(
                        Icons.calendar_today_rounded,
                        'Date & Time',
                        '${report.timestamp.day.toString().padLeft(2, '0')}/${report.timestamp.month.toString().padLeft(2, '0')}/${report.timestamp.year}  ${report.timestamp.hour.toString().padLeft(2, '0')}:${report.timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      const SizedBox(height: 10),
                      _buildMetaRow(Icons.storefront_rounded, 'Establishment', report.businessName),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Captured Image Thumbnail
                GestureDetector(
                  onTap: _showImageZoomDialog,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderLight, width: 1.5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            PackageCanvasWidget(
                              imagePath: report.imagePath,
                              imageBytes: report.imageBytes,
                              sampleTag: report.sampleImageTag,
                              height: 80,
                              showBoundingBoxes: false,
                            ),
                            Container(
                              color: Colors.black.withAlpha(40),
                              child: const Center(
                                child: Icon(Icons.zoom_in_rounded, color: Colors.white, size: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap to zoom',
                        style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Extracted Product Details (mocked)
  Widget _buildExtractedDetailsCard(InspectionReport report) {
    final d = report.productDetails;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.inventory_rounded, color: AppTheme.primaryNavy, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Extracted Product Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppTheme.borderLight),
            const SizedBox(height: 12),

            _buildDetailRow('Brand / Commodity', d.brandName, isBold: true),
            _buildDetailRow('Declared Net Quantity', d.declaredNetQuantity, isHighlight: true),
            _buildDetailRow('Declared MRP', '${d.declaredMrp} (Incl. of all taxes)'),
            _buildDetailRow('Unit Sale Price (USP)', d.unitSalePrice, isHighlight: true),
            _buildDetailRow('Batch / Mfg Date', d.batchMfgDate),
            _buildDetailRow('Manufacturer / Packer', d.manufacturerAddress),
            _buildDetailRow('Consumer Care Redressal', d.consumerCareDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isHighlight ? AppTheme.primaryNavy : AppTheme.textPrimary,
                fontWeight: (isBold || isHighlight) ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Compliance Checklist Card
  Widget _buildComplianceChecklistCard(InspectionReport report) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rule_folder_rounded, color: AppTheme.primaryNavy, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Compliance Checklist (PCR, 2011)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppTheme.borderLight),
            const SizedBox(height: 10),

            ...report.complianceChecks.map((check) => _buildCheckItem(check)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(ComplianceCheck check) {
    final isPass = check.isCompliant;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPass ? AppTheme.passBackground.withAlpha(90) : AppTheme.violationBackground.withAlpha(90),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPass ? AppTheme.passGreen.withAlpha(60) : AppTheme.violationRed.withAlpha(80),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPass ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isPass ? AppTheme.passGreen : AppTheme.violationRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  check.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPass ? AppTheme.passGreen : AppTheme.violationRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  check.statusText.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),

          // Flagged Detail if any (e.g. Found 1.8mm, Required 3.0mm)
          if (check.flaggedDetail != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.violationRed.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: AppTheme.violationRed),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Flagged: ${check.flaggedDetail}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.violationText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (check.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              check.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ],

          const SizedBox(height: 4),
          Text(
            'Reference: ${check.ruleReference}',
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Action Buttons at Bottom: "Save to Logs" & "Print / Share PDF"
  Widget _buildBottomActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary: Save to Logs
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _handleSaveToLogs,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded, size: 20),
            label: Text(
              _isSaving ? 'Saving...' : 'Save to Logs',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary: Print / Share PDF
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _handlePrintSharePdf,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
            ),
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
            label: const Text(
              'Print / Share PDF',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
