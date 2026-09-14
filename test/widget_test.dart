import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legal_metrology_inspector/main.dart';
import 'package:legal_metrology_inspector/ui/screens/login_screen.dart';
import 'package:legal_metrology_inspector/ui/screens/home_screen.dart';

void main() {
  testWidgets('Full 4-Screen Flow Smoke & Navigation Test', (WidgetTester tester) async {
    // Set standard mobile screen dimensions for testing
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch App
    await tester.pumpWidget(const LegalMetrologyInspectorApp());
    await tester.pumpAndSettle();

    // Verify Screen 1: Login Screen is displayed
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Legal Metrology Department'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byIcon(Icons.balance_rounded), findsOneWidget);

    // Tap "Sign In"
    final signInFinder = find.text('Sign In');
    await tester.ensureVisible(signInFinder);
    await tester.tap(signInFinder);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Verify Screen 2: Clean Home Screen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Inspector R. Sharma'), findsWidgets);
    expect(find.text('+ Start New Inspection'), findsOneWidget);
    expect(find.text('Statutory Enforcement Authority'), findsOneWidget);
    expect(find.text('Case Logs'), findsWidgets);
    expect(find.text('Rules & Act'), findsWidgets);

    // Tap on "+ Start New Inspection" to open Screen 3: Capture Screen
    final startInspectionFinder = find.text('+ Start New Inspection');
    await tester.ensureVisible(startInspectionFinder);
    await tester.tap(startInspectionFinder);
    await tester.pumpAndSettle();

    // Verify Screen 3: Capture Screen
    expect(find.text('Capture Package Label'), findsOneWidget);
    expect(find.text('Capture via Camera'), findsOneWidget);
    expect(find.text('Select from Device Gallery'), findsOneWidget);
    expect(find.text('Use Sample Test Package (GoodLife Oil 1L)'), findsOneWidget);

    // Tap "Use Sample Test Package (GoodLife Oil 1L)" to simulate capturing an image
    final sampleFinder = find.text('Use Sample Test Package (GoodLife Oil 1L)');
    await tester.ensureVisible(sampleFinder);
    await tester.tap(sampleFinder);
    await tester.pumpAndSettle();

    // Verify Confirmation View is displayed
    expect(find.text('Is the package label and MRP clearly visible?'), findsOneWidget);
    expect(find.text('Retake Photo'), findsOneWidget);
    expect(find.text('Confirm & Analyze'), findsOneWidget);

    // Tap "Confirm & Analyze"
    final confirmFinder = find.text('Confirm & Analyze');
    await tester.ensureVisible(confirmFinder);
    await tester.tap(confirmFinder);
    await tester.pump(); // Start dialog

    // Verify AI analysis loading dialog is displayed
    expect(find.text('Analyzing label compliance with AI...'), findsOneWidget);

    // Fast-forward past the 2-second mock analysis delay
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Screen 4: Inspection Report Screen is displayed
    expect(find.text('Inspection Memo'), findsOneWidget);
    expect(find.text('Extracted Product Details'), findsOneWidget);
    expect(find.text('GoodLife Refined Oil'), findsWidgets);
    expect(find.text('1 L'), findsOneWidget);
    expect(find.text('₹145.00 (Incl. of all taxes)'), findsOneWidget);
    expect(find.text('Compliance Checklist (PCR, 2011)'), findsOneWidget);
    expect(find.text('Save to Logs'), findsOneWidget);
    expect(find.text('Print / Share PDF'), findsOneWidget);

    // Tap "Save to Logs"
    final saveLogsFinder = find.text('Save to Logs');
    await tester.ensureVisible(saveLogsFinder);
    await tester.tap(saveLogsFinder);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify returning back to Home Screen
    expect(find.byType(HomeScreen), findsOneWidget);

    // Verify Navigation to Tab 1: Case Logs
    final logsTabFinder = find.text('Case Logs').first;
    await tester.ensureVisible(logsTabFinder);
    await tester.tap(logsTabFinder);
    await tester.pumpAndSettle();

    // Verify Inspection Case Logs Screen
    expect(find.text('Inspection Case Logs'), findsOneWidget);
    expect(find.text('Total Audited'), findsOneWidget);
    expect(find.text('GoodLife Refined Oil'), findsWidgets);

    // Verify Navigation to Tab 2: Rules & Act
    final rulesTabFinder = find.text('Rules & Act').first;
    await tester.ensureVisible(rulesTabFinder);
    await tester.tap(rulesTabFinder);
    await tester.pumpAndSettle();

    // Verify Rules & Act Screen
    expect(find.text('Legal Metrology Rules & Act'), findsOneWidget);
    expect(find.text('Standard Weights & Measures Enforcement'), findsOneWidget);
    expect(find.text('Rule 9(1) & Table-I'), findsOneWidget);
    expect(find.text('Mandatory Font Height Schedule (Table-I)'), findsOneWidget);
  });
}
