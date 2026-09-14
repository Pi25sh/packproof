import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// PackageCanvasWidget displays captured package photos cleanly without restrictive frames,
/// or renders a high-fidelity simulated package label when using demo/test mode.
class PackageCanvasWidget extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
  final String? sampleTag;
  final double? height;
  final double? width;
  final BoxFit fit;

  const PackageCanvasWidget({
    super.key,
    this.imagePath,
    this.imageBytes,
    this.sampleTag,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    // Kept for backwards compatibility if passed, but framing overlay is avoided as requested
    bool showBoundingBoxes = false,
  });

  @override
  Widget build(BuildContext context) {
    // Miniature thumbnail mode (for lists/cards)
    if (height != null && height! <= 120 && (imageBytes == null || imageBytes!.isEmpty) && (imagePath == null || imagePath!.isEmpty)) {
      return Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_rounded, size: 26, color: Color(0xFFD97706)),
              SizedBox(height: 2),
              Text(
                'OIL 1L',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
              ),
            ],
          ),
        ),
      );
    }

    Widget content;

    if (imageBytes != null && imageBytes!.isNotEmpty) {
      content = Image.memory(
        imageBytes!,
        fit: fit,
        width: double.infinity,
      );
    } else if (imagePath != null && imagePath!.isNotEmpty && !kIsWeb) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        content = Image.file(
          file,
          fit: fit,
          width: double.infinity,
        );
      } else {
        content = _buildSimulatedPackage();
      }
    } else {
      content = _buildSimulatedPackage();
    }

    return Container(
      height: height ?? 360,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: content),
    );
  }

  Widget _buildSimulatedPackage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Brand Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '★ PREMIUM QUALITY ★',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'GoodLife',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF78350F),
                  ),
                ),
                const Text(
                  'REFINED SUNFLOWER OIL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 12),

                // Simulated Legal Metrology Declarations Panel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MANDATORY DECLARATIONS (RULE 6, PCR 2011)',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Net Quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'NET QUANTITY:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.violationBackground,
                              border: Border.all(color: AppTheme.violationRed, width: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '1 L (Font: 1.8mm ⚠️)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.violationText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // MRP & USP
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('MAX. RETAIL PRICE (MRP):', style: TextStyle(fontSize: 11)),
                          Text('₹145.00', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Text(
                        '(Incl. of all taxes)',
                        style: TextStyle(fontSize: 9, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('UNIT SALE PRICE (USP):', style: TextStyle(fontSize: 11)),
                          Text('₹0.145 / ml', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('BATCH / PKD:', style: TextStyle(fontSize: 10)),
                          Text('B-204 | 08/2026', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                      const Divider(height: 10, thickness: 0.5),
                      const Text(
                        'Mfg By: GoodLife Agrotech Ltd, Plot 42, GIDC, Gujarat - 390010\n'
                        'Consumer Care: care@goodlife.com | 1800-200-333',
                        style: TextStyle(fontSize: 8.5, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
