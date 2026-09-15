import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'dart:async';

class EcommerceAuditScreen extends StatefulWidget {
  const EcommerceAuditScreen({super.key});

  @override
  State<EcommerceAuditScreen> createState() => _EcommerceAuditScreenState();
}

class _EcommerceAuditScreenState extends State<EcommerceAuditScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isAuditing = false;
  bool _auditComplete = false;

  void _runAudit() async {
    if (_urlController.text.isEmpty) return;
    
    setState(() {
      _isAuditing = true;
      _auditComplete = false;
    });
    
    // Simulate scraping and parsing
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _isAuditing = false;
        _auditComplete = true;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Live E-Commerce URL Audit'),
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
                _buildInputSection(),
                const SizedBox(height: 24),
                if (_isAuditing) _buildProgressSection(),
                if (_auditComplete) _buildResultsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInputSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Digital Compliance Scraper',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
            ),
            const SizedBox(height: 8),
            const Text(
              'Paste a product URL from Amazon, Blinkit, Zepto, etc. to audit Rule 6(10A) Country of Origin & mandatory declarations.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Product URL / HTML Snippet',
                hintText: 'https://www.amazon.in/dp/B08XYZ...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link, color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isAuditing ? null : _runAudit,
                icon: const Icon(Icons.travel_explore),
                label: const Text('Run Real-Time Audit'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryBlue),
            const SizedBox(height: 24),
            const Text('Fetching DOM tree...', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Locating Country of Origin filters...', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Text('Checking for Dual MRP Pricing nodes...', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            LinearProgressIndicator(backgroundColor: Colors.grey.shade200, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultsSection() {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppTheme.violationRed, width: 2), // Simulate a failed audit
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppTheme.violationRed, size: 28),
                    SizedBox(width: 8),
                    Text('Audit Failed (2 Violations)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.violationRed)),
                  ],
                ),
                const Divider(height: 32),
                
                // Rule 6(10A) Check
                _buildCheckItem(
                  title: 'Rule 6(10A) Filter Check',
                  subtitle: 'Platform must provide searchable Country of Origin filter',
                  passed: false,
                  reason: 'No discrete <select> or filter param found for Country of Origin.',
                ),
                const SizedBox(height: 16),
                
                // Dual MRP Check
                _buildCheckItem(
                  title: 'Dual MRP Detection',
                  subtitle: 'Illegal dual pricing found in DOM nodes',
                  passed: false,
                  reason: 'Found two distinct MRP values: ₹499 (App) and ₹599 (Web).',
                ),
                const SizedBox(height: 16),
                
                // Mandatory Declarations
                _buildCheckItem(
                  title: '9 Mandatory Pre-Purchase Declarations',
                  subtitle: 'All info (except date of manufacture) must be visible before purchase',
                  passed: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.report, color: AppTheme.violationRed),
            label: const Text('Escalate to Cyber Nodal Officer', style: TextStyle(color: AppTheme.violationRed)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.violationRed)),
          ),
        )
      ],
    );
  }

  Widget _buildCheckItem({required String title, required String subtitle, required bool passed, String? reason}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.cancel, 
          color: passed ? AppTheme.passGreen : AppTheme.violationRed,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              if (!passed && reason != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.violationRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(reason, style: const TextStyle(color: AppTheme.violationRed, fontSize: 11, fontWeight: FontWeight.w500)),
                )
              ]
            ],
          ),
        )
      ],
    );
  }
}
