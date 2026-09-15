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
        content = const Icon(Icons.image_not_supported, color: Colors.white54, size: 40);
      }
    } else {
      content = const Icon(Icons.image_not_supported, color: Colors.white54, size: 40);
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
}
