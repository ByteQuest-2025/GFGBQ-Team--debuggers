import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Free UPI Payment Service using Intent-based payments
/// No transaction charges - direct bank to bank transfer
class UpiService {
  static final UpiService _instance = UpiService._internal();
  factory UpiService() => _instance;
  UpiService._internal();

  // Your business UPI ID (replace with your actual UPI ID)
  // You can create a business UPI ID from any UPI app
  static const String businessUpiId = 'yourbusiness@upi'; // Replace this
  static const String businessName = 'InvestSathi';

  /// Generate UPI payment URL
  static String generateUpiUrl({
    required double amount,
    required String transactionNote,
    String? transactionRef,
    String? upiId,
    String? payeeName,
  }) {
    final params = {
      'pa': upiId ?? businessUpiId,
      'pn': payeeName ?? businessName,
      'am': amount.toStringAsFixed(2),
      'cu': 'INR',
      'tn': transactionNote,
      if (transactionRef != null) 'tr': transactionRef,
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'upi://pay?$queryString';
  }

  /// Launch UPI payment with any installed UPI app
  Future<UpiPaymentResult> initiatePayment({
    required double amount,
    required String fundId,
    required String fundName,
    String? goalId,
  }) async {
    final transactionRef = 'INV${DateTime.now().millisecondsSinceEpoch}';
    final transactionNote = 'Investment in $fundName';

    final upiUrl = generateUpiUrl(
      amount: amount,
      transactionNote: transactionNote,
      transactionRef: transactionRef,
    );

    try {
      final uri = Uri.parse(upiUrl);
      
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          // Payment initiated - user will complete in UPI app
          // In production, verify payment status via webhook or polling
          return UpiPaymentResult(
            status: UpiPaymentStatus.initiated,
            transactionRef: transactionRef,
            amount: amount,
            fundId: fundId,
            goalId: goalId,
          );
        }
      }

      return UpiPaymentResult(
        status: UpiPaymentStatus.noUpiApp,
        transactionRef: transactionRef,
        amount: amount,
        fundId: fundId,
        error: 'No UPI app found. Please install GPay, PhonePe, or Paytm.',
      );
    } catch (e) {
      debugPrint('UPI Error: $e');
      return UpiPaymentResult(
        status: UpiPaymentStatus.failed,
        transactionRef: transactionRef,
        amount: amount,
        fundId: fundId,
        error: e.toString(),
      );
    }
  }

  /// Get list of popular UPI apps with their package names
  static List<UpiApp> get popularUpiApps => [
    UpiApp(
      name: 'Google Pay',
      packageName: 'com.google.android.apps.nbu.paisa.user',
      icon: '💳',
    ),
    UpiApp(
      name: 'PhonePe',
      packageName: 'com.phonepe.app',
      icon: '📱',
    ),
    UpiApp(
      name: 'Paytm',
      packageName: 'net.one97.paytm',
      icon: '💰',
    ),
    UpiApp(
      name: 'BHIM',
      packageName: 'in.org.npci.upiapp',
      icon: '🏦',
    ),
    UpiApp(
      name: 'Amazon Pay',
      packageName: 'in.amazon.mShop.android.shopping',
      icon: '🛒',
    ),
  ];
}

/// UPI Payment Result
class UpiPaymentResult {
  final UpiPaymentStatus status;
  final String transactionRef;
  final double amount;
  final String fundId;
  final String? goalId;
  final String? error;
  final String? upiTransactionId;

  UpiPaymentResult({
    required this.status,
    required this.transactionRef,
    required this.amount,
    required this.fundId,
    this.goalId,
    this.error,
    this.upiTransactionId,
  });

  bool get isSuccess => status == UpiPaymentStatus.success;
  bool get isInitiated => status == UpiPaymentStatus.initiated;
}

enum UpiPaymentStatus {
  success,
  failed,
  initiated,
  pending,
  noUpiApp,
  cancelled,
}

/// UPI App model
class UpiApp {
  final String name;
  final String packageName;
  final String icon;

  UpiApp({
    required this.name,
    required this.packageName,
    required this.icon,
  });
}
