import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Components/resend_timer.dart';

import '../../Models/user_model.dart';
import '../../app_routes.dart';
import '../../state/auth_notifier.dart';

class VerificationPage extends ConsumerStatefulWidget {
  const VerificationPage({super.key});

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  // Controllers to track the input of each digit
  final List<TextEditingController> _emailOtpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _mobileOtpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _emailFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final List<FocusNode> _mobileFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    for (var controller in _emailOtpControllers) {
      controller.dispose();
    }
    for (var controller in _mobileOtpControllers) {
      controller.dispose();
    }
    for (var node in _emailFocusNodes) {
      node.dispose();
    }
    for (var node in _mobileFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Helper function to concatenate the 6 digits
  String _getOtpCode(List<TextEditingController> controllers) {
    return controllers.map((c) => c.text).join();
  }

  // Helper function to check if all fields in both sets are filled
  bool _checkIfAllFilled() {
    for (var controller in _emailOtpControllers) {
      if (controller.text.isEmpty) return false;
    }
    for (var controller in _mobileOtpControllers) {
      if (controller.text.isEmpty) return false;
    }
    return true;
  }

  // Helper widget to build the OTP field
  Widget _buildOtpField(
    int index,
    List<TextEditingController> controllers,
    List<FocusNode> nodes,
  ) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controllers[index],
        focusNode: nodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            // Move focus to the next field if a digit is entered
            if (index < controllers.length - 1) {
              nodes[index + 1].requestFocus();
            } else {
              nodes[index].unfocus();
            }
          } else if (value.isEmpty) {
            // Move focus to the previous field if a digit is deleted
            if (index > 0) {
              nodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }

  // Updated helper widget to use focus nodes
  Widget _buildOtpRow(
    String label,
    List<TextEditingController> controllers,
    List<FocusNode> nodes,
  ) {
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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return _buildOtpField(index, controllers, nodes);
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for verification success
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous != null &&
          previous.isLoading &&
          next.error == null &&
          next.tempEmail == null) {
        // Verification is completed (or forgot password was successfully reset/confirmed), navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification successful. Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      } else if (next.error != null) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    Color backgroundColor = Theme.of(context).primaryColor;
    final authState = ref.watch(authNotifierProvider);
    final isSubmitting = authState.isLoading;
    final tempEmail = authState.tempEmail;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Messenger has sent a code to\nverify your account (${tempEmail ?? '...'})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Pass controllers and focus nodes
                      _buildOtpRow('Email OTP', _emailOtpControllers, _emailFocusNodes),
                      const SizedBox(height: 25),
                      _buildOtpRow('Mobile OTP', _mobileOtpControllers, _mobileFocusNodes),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isSubmitting || tempEmail == null ? null : () {
                            if (_checkIfAllFilled()) {
                              final emailOtp = _getOtpCode(_emailOtpControllers);
                              final mobileOtp = _getOtpCode(_mobileOtpControllers);

                              // Check the two OTPs against the backend
                              ref.read(authNotifierProvider.notifier).verifyEmail(emailOtp);
                              ref.read(authNotifierProvider.notifier).verifyPhone(tempEmail, mobileOtp);

                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter all 6 digits for both Email and Mobile OTP.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isSubmitting
                              ? const CircularProgressIndicator(color: Color(0xFF003B5C))
                              : Text(
                            'Verify',
                            style: TextStyle(
                              color: backgroundColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const ResendTimer(),
                    ],
                  ),
                ),
              ),
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
    );
  }
}
