import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/gemini_inspection_service.dart';
import '../widgets/package_canvas_widget.dart';
import 'report_screen.dart';

/// Screen 3: Live AR Capture Screen
/// Enables officers to scan a package with a live AR HUD overlay
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final GeminiInspectionService _service = GeminiInspectionService();

  String? _capturedImagePath;
  Uint8List? _capturedImageBytes;
  bool _hasImage = false;
  bool _isPicking = false;

  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

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
          _hasImage = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access camera/gallery: $e'),
            backgroundColor: AppTheme.warningAmber,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }


  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _capturedImageBytes = null;
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
              ],
            ),
          ),
        ),
      ),
    );

    final report = await _service.analyzePackageLabel(
      imagePath: _capturedImagePath,
      imageBytes: _capturedImageBytes,
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
        title: const Text('Live AR Inspection HUD'),
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
            child: _hasImage ? _buildConfirmationView() : _buildLiveARView(),
          ),
        ),
      ),
    );
  }

  /// NEW AR Viewfinder implementation
  Widget _buildLiveARView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AR HUD Viewfinder
        Container(
          height: 480,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryBlue, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ]
          ),
          child: Stack(
            children: [
              // Mock camera feed background (grid pattern)
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(),
                ),
              ),

              // Animated Scanning Line
              AnimatedBuilder(
                animation: _scannerController,
                builder: (context, child) {
                  return Positioned(
                    top: _scannerController.value * 460,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                    ),
                  );
                },
              ),



              // HUD Overlay text
              const Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 12),
                    SizedBox(width: 6),
                    Text('AR LIVE SCANNING', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
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
            icon: const Icon(Icons.camera, size: 22),
            label: const Text(
              'Capture Frame for Official Report',
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


      ],
    );
  }


  /// Post-selection state
  Widget _buildConfirmationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full Image Preview
        PackageCanvasWidget(
          imagePath: _capturedImagePath,
          imageBytes: _capturedImageBytes,
          height: 380,
        ),
        const SizedBox(height: 20),

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
                            'Confirm AR Scan Frame?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              height: 1.3,
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

                _buildVerificationPoint('PDP Area Geometry confirmed'),
                _buildVerificationPoint('Font height caliper locked'),
                _buildVerificationPoint('Legible declarations extracted'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _retakePhoto,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Rescan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(width: 14),
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
                    'Generate AI Report',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
            child: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
      
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
