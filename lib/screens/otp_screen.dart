import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegistration;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.isRegistration,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus first field
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
            _startResendTimer();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all fields are filled
    if (index == 5 && value.isNotEmpty) {
      final otp = _otpControllers.map((c) => c.text).join();
      if (otp.length == 6) {
        _verifyOtp(otp);
      }
    }
  }

  Future<void> _verifyOtp(String otp) async {
    // In real app, verify OTP with backend
    // For now, accept any 6-digit OTP
    if (otp.length != 6) {
      _showError('Please enter complete OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Save login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('phone_number', widget.phoneNumber);
    if (widget.isRegistration) {
      await prefs.setBool('has_seen_onboarding', true);
    }

    setState(() {
      _isLoading = false;
    });

    // Navigate to home
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });

    _startResendTimer();

    // In real app, call API to resend OTP
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent successfully'),
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  String _getOtp() {
    return _otpControllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Title
              Text(
                'Verify OTP',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.pureBlack,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.blackSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '+91 ${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.pureBlack,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              const SizedBox(height: 48),
              
              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.pureBlack,
                          ),
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.dividerColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.dividerColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.pureBlack, width: 2),
                        ),
                      ),
                      onChanged: (value) => _onOtpChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          final otp = _getOtp();
                          if (otp.length == 6) {
                            _verifyOtp(otp);
                          } else {
                            _showError('Please enter complete OTP');
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.warmWhite),
                          ),
                        )
                      : const Text('Verify'),
                ),
              ),
              const SizedBox(height: 24),
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                  if (_canResend)
                    TextButton(
                      onPressed: _resendOtp,
                      child: const Text('Resend OTP'),
                    )
                  else
                    Text(
                      'Resend in $_resendTimer s',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.blackSecondary,
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

