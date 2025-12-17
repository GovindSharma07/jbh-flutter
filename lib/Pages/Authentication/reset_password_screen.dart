import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_routes.dart';
import '../../state/auth_notifier.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Reusable widget pattern consistent with Login/Register pages
  Widget _buildTextFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? !_isPasswordVisible : false,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black87),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(
              color: Color(0xFFFF6B00), // Orange/Red for error visibility
              fontWeight: FontWeight.bold,
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
                : null,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final primaryColor = Theme.of(context).primaryColor;
    final isSubmitting = authState.isLoading;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous?.isLoading == true && next.error == null && next.tempEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password Reset Successful! Please Login."), backgroundColor: Colors.green));
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error!), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      backgroundColor: primaryColor, // Dark Blue Background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Reset Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              'Enter the OTP sent to your email\nand your new password.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          _buildTextFormField(
                            label: 'OTP Code',
                            hint: 'Enter 6-digit Code',
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.length != 6 ? "Enter 6 digit OTP" : null,
                          ),

                          _buildTextFormField(
                            label: 'New Password',
                            hint: 'Enter New Password',
                            controller: _newPasswordController,
                            isPassword: true,
                            validator: (v) => v!.length < 8 ? "Min 8 characters" : null,
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // White button
                                foregroundColor: primaryColor, // Text matches background
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              onPressed: isSubmitting ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  ref.read(authNotifierProvider.notifier).resetPassword(
                                    _otpController.text,
                                    _newPasswordController.text,
                                  );
                                }
                              },
                              child: isSubmitting
                                  ? CircularProgressIndicator(color: primaryColor)
                                  : Text(
                                "Reset Password",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer Section (Logo & URL)
                Column(
                  children: [
                    Image.asset(
                      'assets/icons/jbh_logo.png',
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.public,
                          color: Colors.green,
                          size: 50,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'www.jbhtechacademy.com',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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