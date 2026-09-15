import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';

class NoticeGenerationScreen extends StatefulWidget {
  const NoticeGenerationScreen({super.key});

  @override
  State<NoticeGenerationScreen> createState() => _NoticeGenerationScreenState();
}

class _NoticeGenerationScreenState extends State<NoticeGenerationScreen> {
  bool _isGenerating = false;
  bool _isGenerated = false;

  void _generateNotice() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate PDF creation
    setState(() {
      _isGenerating = false;
      _isGenerated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Official Forms & Notices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Administrative Action Hub',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Generate official Seventh Schedule Forms and Jan Vishwas Act Improvement Notices.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 24),
                if (!_isGenerated) _buildGenerationOptions() else _buildGeneratedNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerationOptions() {
    return Column(
      children: [
        _buildActionCard(
          title: '7th Schedule Form A (Weight/Mass)',
          subtitle: 'Generate field data sheet with Geotags and Officer Signature',
          icon: Icons.scale_rounded,
          onTap: _generateNotice,
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          title: 'Section 15(6) Improvement Notice',
          subtitle: 'Issue a QR-Coded statutory cure notice under Jan Vishwas Act 2026',
          icon: Icons.gavel_rounded,
          onTap: _generateNotice,
        ),
        const SizedBox(height: 24),
        if (_isGenerating)
          const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Compiling PDF, embedding Geotags & Timestamp...', style: TextStyle(color: AppTheme.primaryBlue)),
            ],
          )
      ],
    );
  }

  Widget _buildGeneratedNotice() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: AppTheme.passGreen, size: 28),
                SizedBox(width: 8),
                Text('Notice Generated Successfully', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 32),
            const Text('Jan Vishwas Act 2026 - Improvement Notice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
            const SizedBox(height: 8),
            const Text('Notice ID: JV-2026-IND-8924'),
            const SizedBox(height: 4),
            const Text('Issued: 15 Sept 2026 | GPS: 28.6139° N, 77.2090° E', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: QrImageView(
                data: 'https://legal-metrology-portal.gov.in/track/JV-2026-IND-8924',
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Manufacturer Portal Tracker',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan QR code to view violation evidence and track the 15-day statutory cure deadline.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.print),
                label: const Text('Print / Share PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _isGenerated = false),
              child: const Text('Generate Another Document'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
