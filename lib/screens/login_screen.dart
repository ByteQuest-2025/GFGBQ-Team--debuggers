import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true; // Toggle between login and registration

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navigate to OTP screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phoneNumber: _phoneController.text.trim(),
          name: _isLogin ? null : _nameController.text.trim(),
          isRegistration: !_isLogin,
        ),
      ),
    );
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // Title
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.pureBlack,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Login to continue your investment journey'
                      : 'Start your investment journey today',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.blackSecondary,
                      ),
                ),
                const SizedBox(height: 48),
                
                // Name input (only for registration)
                if (!_isLogin) ...[
                  Text(
                    'Name',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: AppColors.blackSecondary),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.dividerColor),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.dividerColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.pureBlack, width: 1),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                ],
                
                // Phone number input
                Text(
                  'Phone Number',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.pureBlack,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Country code
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        '+91',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.pureBlack,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Phone number field
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter 10-digit number',
                          hintStyle: TextStyle(color: AppColors.blackSecondary),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.dividerColor),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.dividerColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.pureBlack, width: 1),
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.pureBlack,
                            ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.warmWhite),
                            ),
                          )
                        : Text(_isLogin ? 'Login' : 'Continue'),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Toggle between login and registration
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? "Don't have an account? "
                          : 'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.blackSecondary,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin ? 'Register' : 'Login',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

