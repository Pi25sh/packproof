import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'dart:async';

class CitizenReportScreen extends StatefulWidget {
  const CitizenReportScreen({super.key});

  @override
  State<CitizenReportScreen> createState() => _CitizenReportScreenState();
}

class _CitizenReportScreenState extends State<CitizenReportScreen> {
  bool _isReporting = false;
  bool _isReported = false;

  void _submitReport() async {
    setState(() => _isReporting = true);
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real implementation, this would send a WebSocket payload to the HQ dashboard.
    // For this mock MVP, the HQ dashboard can listen to a shared mock stream or we just 
    // demonstrate the flow visually. We'll show a success message here.
    
    if (mounted) {
      setState(() {
        _isReporting = false;
        _isReported = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Citizen MRP Scanner'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400), // Mobile app look
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _isReported ? _buildSuccessView() : _buildReportingView(),
          ),
        ),
      ),
    );
  }

  Widget _buildReportingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fake camera viewfinder
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1596522354195-e836932a39d4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('MRP: ₹145.00 Detected', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, backgroundColor: Colors.black54)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        const Text('Retailer Charged:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            prefixText: '₹ ',
            border: OutlineInputBorder(),
            hintText: 'Enter amount paid'
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: '160.00'),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Expanded(child: Text('Overcharge Detected: ₹15.00 above printed MRP.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isReporting ? null : _submitReport,
            icon: _isReporting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Icon(Icons.campaign),
            label: Text(_isReporting ? 'Sending Alert...' : 'Report Overcharge to HQ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        const SizedBox(height: 24),
        const Text(
          'Alert Sent Successfully!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your report under Rule 21(1)(i) has been transmitted instantly to the DoCA HQ Central Heatmap.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to Home'),
        )
      ],
    );
  }
}
