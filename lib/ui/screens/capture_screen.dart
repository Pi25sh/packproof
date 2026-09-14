import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/mock_inspection_service.dart';
import '../widgets/package_canvas_widget.dart';
import 'report_screen.dart';

/// Screen 3: Image Capture & Confirmation Screen
/// Enables officers to capture a package photo via camera or gallery,
/// confirm image clarity, and trigger AI compliance analysis with a 2-second loading overlay.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final MockInspectionService _service = MockInspectionService();

  String? _capturedImagePath;
  Uint8List? _capturedImageBytes;
  String? _sampleTag;
  bool _hasImage = false;
  bool _isPicking = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPicking = true);
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _capturedImagePath = file.path;
          _capturedImageBytes = bytes;
          _sampleTag = null;
          _hasImage = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access camera/gallery: $e. Using simulated package.'),
            backgroundColor: AppTheme.warningAmber,
          ),
        );
        _useSamplePackage();
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  void _useSamplePackage() {
    setState(() {
      _capturedImagePath = null;
      _capturedImageBytes = null;
      _sampleTag = 'goodlife_oil';
      _hasImage = true;
    });
  }

  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _capturedImageBytes = null;
      _sampleTag = null;
      _hasImage = false;
    });
  }

  Future<void> _confirmAndAnalyze() async {
    // Show smooth loading dialog/overlay with spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 54,
                  height: 54,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Analyzing label compliance with AI...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Reading mandatory declarations, computing Unit Sale Price, and verifying minimum font height requirements under PCR 2011...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Legal Metrology AI Engine v2.4',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Call service with mock delay (2 seconds)
    final report = await _service.analyzePackageLabel(
      imagePath: _capturedImagePath,
      imageBytes: _capturedImageBytes,
      sampleTag: _sampleTag,
    );

    if (!mounted) return;

    // Dismiss loading dialog
    Navigator.of(context, rootNavigator: true).pop();

    // Navigate to Inspection Report Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReportScreen(report: report, isSavedRecord: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Capture Package Label'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _hasImage ? _buildConfirmationView() : _buildSelectionView(),
          ),
        ),
      ),
    );
  }

  /// Initial state: Officer chooses camera, gallery, or sample test package
  Widget _buildSelectionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Instructions Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppTheme.primaryBlue, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Position the Principal Display Panel (PDP) and MRP markings flatly in frame under even illumination.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Interactive Viewfinder Placeholder
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderLight, width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Reticle Guides
              Container(
                width: 240,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.document_scanner_rounded,
                        size: 52,
                        color: Colors.white.withAlpha(180),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ready to inspect package',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Select an option below to proceed',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Primary: Camera Capture
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isPicking ? null : () => _pickImage(ImageSource.camera),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.photo_camera_rounded, size: 22),
            label: const Text(
              'Capture via Camera',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary: Choose from Gallery
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isPicking ? null : () => _pickImage(ImageSource.gallery),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
            ),
            icon: const Icon(Icons.photo_library_outlined, size: 20),
            label: const Text(
              'Select from Device Gallery',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Third Option: Sample Test Package (Ideal for testing on desktop / browser without real packaging)
        Material(
          color: AppTheme.accentGold.withAlpha(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: AppTheme.accentGold.withAlpha(60)),
          ),
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.science_outlined, color: Color(0xFFB45309)),
            title: const Text(
              'Use Sample Test Package (GoodLife Oil 1L)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF92400E),
              ),
            ),
            subtitle: const Text(
              'Simulate immediate field scan of sunflower oil package',
              style: TextStyle(fontSize: 11, color: Color(0xFF78350F)),
            ),
            trailing: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFFB45309)),
            onTap: _useSamplePackage,
          ),
        ),
      ],
    );
  }

  /// Post-selection state: Full image preview + Confirmation Card + Retake / Confirm buttons
  Widget _buildConfirmationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full Image Preview - wide, natural view without restrictive framing
        PackageCanvasWidget(
          imagePath: _capturedImagePath,
          imageBytes: _capturedImageBytes,
          sampleTag: _sampleTag,
          height: 380,
        ),
        const SizedBox(height: 20),

        // Confirmation Card below image
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppTheme.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.visibility_rounded,
                        color: AppTheme.primaryBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Is the package label and MRP clearly visible?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ensure declarations are sharp, legible, and unblurred for automated compliance audit.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.borderLight),
                const SizedBox(height: 14),

                // Checklist validation points
                _buildVerificationPoint('Principal Display Panel (PDP) within frame'),
                _buildVerificationPoint('Declared Net Quantity & MRP digits readable'),
                _buildVerificationPoint('No severe flash glare or label folding'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Two Action Buttons: "Retake Photo" and "Confirm & Analyze"
        Row(
          children: [
            // Retake Photo Button
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _retakePhoto,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Retake Photo',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Confirm & Analyze Button
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _confirmAndAnalyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 20),
                  label: const Text(
                    'Confirm & Analyze',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildVerificationPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppTheme.passGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
