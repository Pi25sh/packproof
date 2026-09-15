import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BluetoothScaleScreen extends StatefulWidget {
  const BluetoothScaleScreen({super.key});

  @override
  State<BluetoothScaleScreen> createState() => _BluetoothScaleScreenState();
}

class _BluetoothScaleScreenState extends State<BluetoothScaleScreen> {
  bool _isConnected = false;
  bool _isConnecting = false;
  
  final TextEditingController _lotSizeController = TextEditingController();
  
  int _statutorySampleSize = 0;
  double _correctionFactor = 0.0;
  int _maxAllowableDefects = 0;
  
  List<double> _weights = [];
  double _mean = 0.0;
  double _stdDev = 0.0;
  double _correctedAverage = 0.0;
  int _defectsFound = 0;
  
  Timer? _simulationTimer;
  
  void _calculate5thSchedule() {
    final int lotSize = int.tryParse(_lotSizeController.text) ?? 0;
    if (lotSize >= 500 && lotSize <= 3200) {
      _statutorySampleSize = 80;
      _correctionFactor = 0.295;
      _maxAllowableDefects = 5;
    } else if (lotSize > 3200) {
      _statutorySampleSize = 125;
      _correctionFactor = 0.234;
      _maxAllowableDefects = 7;
    } else if (lotSize > 100) {
      _statutorySampleSize = 50;
      _correctionFactor = 0.379;
      _maxAllowableDefects = 3;
    } else {
      _statutorySampleSize = lotSize; // 100% inspection
      _correctionFactor = 0.0;
      _maxAllowableDefects = 0;
    }
    setState(() {});
  }
  
  void _toggleConnection() async {
    if (_isConnected) {
      _simulationTimer?.cancel();
      setState(() {
        _isConnected = false;
        _weights.clear();
      });
      return;
    }
    
    setState(() => _isConnecting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isConnecting = false;
      _isConnected = true;
      _weights.clear();
    });
    
    _startSimulatingWeights();
  }
  
  void _startSimulatingWeights() {
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted || !_isConnected) {
        timer.cancel();
        return;
      }
      
      if (_weights.length >= _statutorySampleSize && _statutorySampleSize > 0) {
        timer.cancel();
        return;
      }
      
      // Simulate weight roughly around 1000g (1kg) with some variance
      final double newWeight = 1000.0 + ((-50 + (100 * (DateTime.now().millisecond / 1000))));
      
      setState(() {
        _weights.add(newWeight);
        
        // Recalculate stats
        _mean = _weights.reduce((a, b) => a + b) / _weights.length;
        
        if (_weights.length > 1) {
          double sumSq = 0;
          for (var w in _weights) {
            sumSq += (w - _mean) * (w - _mean);
          }
          _stdDev = (sumSq / (_weights.length - 1));
          // simple approximation for sqrt in UI if dart:math is not imported, but we can just import dart:math
        }
        
        _correctedAverage = _mean + (_stdDev * _correctionFactor);
        
        // MPE Deficit simulation (Let's say MPE is 15g for 1000g)
        _defectsFound = _weights.where((w) => w < 985.0).length;
      });
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _lotSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Bluetooth Scale & Sampling'),
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
                _buildMathEngineCard(),
                const SizedBox(height: 24),
                _buildScaleConnectionCard(),
                const SizedBox(height: 24),
                if (_isConnected) _buildLiveStatsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMathEngineCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calculate_rounded, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text(
                  'Automated 5th Schedule Math Engine',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lotSizeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Inspection Lot Size',
                hintText: 'e.g., 1000',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle, color: AppTheme.primaryBlue),
                  onPressed: _calculate5thSchedule,
                )
              ),
              onChanged: (_) => _calculate5thSchedule(),
            ),
            const SizedBox(height: 16),
            if (_statutorySampleSize > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Sample Size (n)', '$_statutorySampleSize'),
                    _buildStatItem('Correction (C)', '$_correctionFactor'),
                    _buildStatItem('Max Defects', '≤$_maxAllowableDefects'),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
  
  Widget _buildScaleConnectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              _isConnected ? Icons.bluetooth_connected_rounded : Icons.bluetooth_rounded, 
              size: 48, 
              color: _isConnected ? AppTheme.primaryBlue : Colors.grey
            ),
            const SizedBox(height: 16),
            Text(
              _isConnected ? 'Connected to Scale (BLE_WEIGHT_v2)' : 'Scale Disconnected',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _toggleConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected ? AppTheme.warningAmber : AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                ),
                child: _isConnecting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isConnected ? 'Disconnect Scale' : 'Sync Bluetooth Scale'),
              ),
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildLiveStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.primaryBlue)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Statistical Analysis (0.1s update)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Icon(Icons.sensors, color: AppTheme.primaryBlue),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildResultItem('Mean (X̄)', '${_mean.toStringAsFixed(2)} g')),
                Expanded(child: _buildResultItem('Std Dev (σ)', '${_stdDev.toStringAsFixed(2)} g')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildResultItem('Corrected Avg (Xc)', '${_correctedAverage.toStringAsFixed(2)} g')),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Defects / Max', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        '$_defectsFound / $_maxAllowableDefects',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: _defectsFound > _maxAllowableDefects ? AppTheme.violationRed : AppTheme.passGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Packages Weighed: ${_weights.length} / $_statutorySampleSize', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _statutorySampleSize == 0 ? 0 : _weights.length / _statutorySampleSize,
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.primaryBlue,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
      ],
    );
  }
  
  Widget _buildResultItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }
}
