import 'package:flutter/material.dart';

/// Payment result callback types
typedef PaymentSuccessCallback = void Function(PaymentResult result);
typedef PaymentErrorCallback = void Function(String error);

/// Payment result model
class PaymentResult {
  final String paymentId;
  final String orderId;
  final String signature;
  final double amount;
  final String fundId;
  final String? goalId;

  PaymentResult({
    required this.paymentId,
    required this.orderId,
    required this.signature,
    required this.amount,
    required this.fundId,
    this.goalId,
  });
}

/// Mock Payment Service for Demo
/// For production, integrate with Razorpay, PayU, or other payment gateways
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  /// Simulate payment processing
  Future<PaymentResult?> processPayment({
    required double amount,
    required String fundId,
    required String fundName,
    required String userName,
    required String userPhone,
    String? goalId,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate 95% success rate
    final isSuccess = DateTime.now().millisecond % 20 != 0;

    if (isSuccess) {
      return PaymentResult(
        paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        signature: 'sig_demo_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        fundId: fundId,
        goalId: goalId,
      );
    }
    return null;
  }
}

/// UPI Payment Helper
class UpiPaymentHelper {
  /// Generate UPI payment URL for deep linking
  static String generateUpiUrl({
    required String upiId,
    required String payeeName,
    required double amount,
    required String transactionNote,
    String? transactionRef,
  }) {
    final params = {
      'pa': upiId,
      'pn': payeeName,
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

  /// UPI app package names for intent
  static const Map<String, String> upiApps = {
    'gpay': 'com.google.android.apps.nbu.paisa.user',
    'phonepe': 'com.phonepe.app',
    'paytm': 'net.one97.paytm',
    'bhim': 'in.org.npci.upiapp',
    'amazonpay': 'in.amazon.mShop.android.shopping',
  };
}

/*
=============================================================================
RAZORPAY INTEGRATION GUIDE (For Production)
=============================================================================

1. Add dependency to pubspec.yaml:
   razorpay_flutter: ^1.3.7

2. Get API keys from: https://dashboard.razorpay.com/app/keys

3. Android Setup (android/app/build.gradle):
   - minSdkVersion should be 19 or higher
   - Add proguard rules if using minification

4. iOS Setup:
   - Add to Info.plist for UPI apps

5. Implementation:

import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;
  
  void init() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleWallet);
  }
  
  void startPayment({
    required double amount,
    required String orderId,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) {
    final options = {
      'key': 'rzp_test_YOUR_KEY', // Replace with your key
      'amount': (amount * 100).toInt(), // Amount in paise
      'currency': 'INR',
      'name': 'InvestSathi',
      'description': 'Investment',
      'order_id': orderId, // Create order on backend first
      'prefill': {
        'name': userName,
        'email': userEmail,
        'contact': userPhone,
      },
      'theme': {'color': '#2E7D32'},
    };
    
    _razorpay.open(options);
  }
  
  void _handleSuccess(PaymentSuccessResponse response) {
    // Verify payment on backend
    // response.paymentId, response.orderId, response.signature
  }
  
  void _handleError(PaymentFailureResponse response) {
    // Handle error: response.code, response.message
  }
  
  void _handleWallet(ExternalWalletResponse response) {
    // Handle external wallet: response.walletName
  }
  
  void dispose() {
    _razorpay.clear();
  }
}

=============================================================================
BACKEND REQUIREMENTS FOR PRODUCTION
=============================================================================

1. Create Order API:
   - Generate order_id using Razorpay Orders API
   - Store order details in database

2. Verify Payment API:
   - Verify signature using: 
     generated_signature = hmac_sha256(order_id + "|" + payment_id, secret)
   - Compare with received signature

3. Webhook Handler:
   - Handle payment.captured, payment.failed events
   - Update investment status in database

4. BSE StAR MF / NSE NMF Integration:
   - For actual mutual fund transactions
   - Requires RIA/Distributor registration

=============================================================================
*/
