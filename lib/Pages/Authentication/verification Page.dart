import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/resend_timer.dart';

import '../../app_routes.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  // Controllers to track the input of each digit
  final List<TextEditingController> _emailOtpControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _mobileOtpControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );

  @override
  void dispose() {
    // Clean up controllers
    for (var controller in _emailOtpControllers) {
      controller.dispose();
    }
    for (var controller in _mobileOtpControllers) {
      controller.dispose();
    }
    super.dispose();
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

  // Updated helper widget to accept the list of controllers
  Widget _buildOtpRow(String label, List<TextEditingController> controllers) {
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
          children: List.generate(5, (index) {
            return Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: controllers[index],
                // Assign controller
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  if (value.length == 1) {
                    FocusScope.of(context).nextFocus();
                  }
                  // Optional: You could also auto-focus previous on deletion
                  // if (value.isEmpty && index > 0) FocusScope.of(context).previousFocus();
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).primaryColor;

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
                      const Text(
                        'Messenger has sent a code to\nverify your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Pass the specific controller lists to the widget
                      _buildOtpRow('Email OTP', _emailOtpControllers),
                      const SizedBox(height: 25),
                      _buildOtpRow('Mobile OTP', _mobileOtpControllers),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            // VALIDATION CHECK BEFORE PROCEEDING
                            if (_checkIfAllFilled()) {
                              // All good, proceed
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                (route) => false,
                              );
                            } else {
                              // Show error if not all filled
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter all digits for both Email and Mobile OTP.',
                                  ),
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
                          child: Text(
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

                      ResendTimer(),
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
