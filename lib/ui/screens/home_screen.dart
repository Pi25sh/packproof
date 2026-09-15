import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import 'capture_screen.dart';
import 'login_screen.dart';
import 'logs_screen.dart';
import 'rules_screen.dart';
import 'bluetooth_scale_screen.dart';
import 'notice_generation_screen.dart';
import 'ecommerce_audit_screen.dart';
import 'citizen_report_screen.dart';

/// Screen 2: Home Screen / Main Officer Portal
class HomeScreen extends StatefulWidget {
  final int initialTabIndex;

  const HomeScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  bool _showHeatmapAlert = false;
  Timer? _alertTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    
    // Simulate incoming citizen alert after 10 seconds for the demo
    _alertTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showHeatmapAlert = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _alertTimer?.cancel();
    super.dispose();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of the Legal Metrology portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.violationRed),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _navigateToCapture() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CaptureScreen()),
    );

    if (result == true && mounted) {
      setState(() => _currentIndex = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildInspectionPortalView(),
          const LogsScreen(),
          const RulesScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.borderLight, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryNavy),
              label: 'HQ Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment_rounded, color: AppTheme.primaryNavy),
              label: 'Case Logs',
            ),
            NavigationDestination(
              icon: Icon(Icons.gavel_outlined),
              selectedIcon: Icon(Icons.gavel_rounded, color: AppTheme.primaryNavy),
              label: 'Rules & Act',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionPortalView() {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DoCA HQ Dashboard',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Central Server connected',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFCBD5E1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Wider for dashboard look
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // Live Heatmap Alerts
              _buildLiveHeatmapAlerts(),
              const SizedBox(height: 24),

              // Primary Action: "+ Start New Inspection"
              _buildPrimaryActionButton(),
              const SizedBox(height: 24),

              const Text('Advanced Inspection Tools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              
              // MVP Grid
              _buildMvpFeaturesGrid(),
              const SizedBox(height: 28),

              // Statutory Instructions & Legal Notice
              _buildStatutoryNotice(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveHeatmapAlerts() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.map_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Live India Violation Heatmap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                if (_showHeatmapAlert)
                  Positioned(
                    top: 80,
                    left: 120,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 12, spreadRadius: 4)],
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning, color: Colors.white, size: 20),
                                SizedBox(height: 4),
                                Text('Rule 21(1)(i)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text('Citizen Report', style: TextStyle(color: Colors.white, fontSize: 9)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (!_showHeatmapAlert)
                  const Center(
                    child: Text('Monitoring all zones...', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withAlpha(45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _navigateToCapture,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.view_in_ar_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+ Live AR Inspection Viewfinder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Virtual calipers, PDP Area, Real-time status',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMvpFeaturesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 600 ? 2.5 : 3.5,
          children: [
            _buildResourceTile(
              icon: Icons.bluetooth_rounded,
              title: 'BLE Scale Sync',
              subtitle: '5th Schedule Math Engine',
              accentColor: Colors.blueAccent,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BluetoothScaleScreen())),
            ),
            _buildResourceTile(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Notices & Forms',
              subtitle: 'Form A/B & Jan Vishwas QR',
              accentColor: Colors.orangeAccent,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NoticeGenerationScreen())),
            ),
            _buildResourceTile(
              icon: Icons.travel_explore,
              title: 'E-Commerce Audit',
              subtitle: 'Live Rule 6(10A) Scraper',
              accentColor: Colors.purpleAccent,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EcommerceAuditScreen())),
            ),
            _buildResourceTile(
              icon: Icons.smartphone,
              title: 'Citizen App (Demo)',
              subtitle: 'Trigger HQ Alerts',
              accentColor: Colors.redAccent,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CitizenReportScreen())),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatutoryNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_rounded, size: 16, color: AppTheme.primaryNavy),
              SizedBox(width: 6),
              Text(
                'Statutory Enforcement Authority',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryNavy,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Under Section 15 of The Legal Metrology Act, 2009, inspecting officers are empowered to inspect packages, record violations under Rule 6 of PCR 2011, and generate official Form II memos. All saved inspection logs and PDF certificates are recorded with digital audit timestamps.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
