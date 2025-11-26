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
  final List<TextEditingController> _emailOtpControllers = List.generate(6, (index) => TextEditingController());
  final List<TextEditingController> _mobileOtpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _emailFocusNodes = List.generate(6, (index) => FocusNode());
  final List<FocusNode> _mobileFocusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var c in _emailOtpControllers) c.dispose();
    for (var c in _mobileOtpControllers) c.dispose();
    for (var n in _emailFocusNodes) n.dispose();
    for (var n in _mobileFocusNodes) n.dispose();
    super.dispose();
  }

  String _getOtpCode(List<TextEditingController> controllers) => controllers.map((c) => c.text).join();

  // Updated to only check required fields
  bool _checkIfAllFilled(bool showEmail, bool showPhone) {
    if (showEmail) {
      for (var c in _emailOtpControllers) if (c.text.isEmpty) return false;
    }
    if (showPhone) {
      for (var c in _mobileOtpControllers) if (c.text.isEmpty) return false;
    }
    return true;
  }

  Widget _buildOtpField(int index, List<TextEditingController> controllers, List<FocusNode> nodes) {
    return Container(
      width: 45,
      height: 50,
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
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (index < controllers.length - 1) nodes[index + 1].requestFocus();
            else nodes[index].unfocus();
          } else if (value.isEmpty && index > 0) {
            nodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildOtpRow(String label, List<TextEditingController> controllers, List<FocusNode> nodes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOtpField(index, controllers, nodes)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous != null && previous.isLoading && !next.isLoading && next.error == null && next.tempEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification successful. Please log in.'), backgroundColor: Colors.green),
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      } else if (next.error != null && (previous == null || next.error != previous?.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    Color backgroundColor = Theme.of(context).primaryColor;
    final authState = ref.watch(authNotifierProvider);
    final isSubmitting = authState.isLoading;
    final tempEmail = authState.tempEmail;

    // Determine what to show based on state flags
    final bool showEmail = !authState.isEmailVerified;
    final bool showPhone = !authState.isPhoneVerified;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text('Verification', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        'We have sent codes for account: ${tempEmail ?? '...'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 40),

                      // Conditionally Render Email OTP Row
                      if (showEmail) ...[
                        _buildOtpRow('Email OTP', _emailOtpControllers, _emailFocusNodes),
                        const SizedBox(height: 25),
                      ],

                      // Conditionally Render Mobile OTP Row
                      if (showPhone) ...[
                        _buildOtpRow('Mobile OTP', _mobileOtpControllers, _mobileFocusNodes),
                        const SizedBox(height: 40),
                      ],

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isSubmitting || tempEmail == null
                              ? null
                              : () {
                            if (_checkIfAllFilled(showEmail, showPhone)) {
                              // Only get code if the field is shown
                              final emailOtp = showEmail ? _getOtpCode(_emailOtpControllers) : null;
                              final mobileOtp = showPhone ? _getOtpCode(_mobileOtpControllers) : null;

                              ref.read(authNotifierProvider.notifier).verifyOtps(emailOtp, mobileOtp);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please complete all verification fields.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.white),
                            foregroundColor: WidgetStateProperty.all(backgroundColor),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                            overlayColor: WidgetStateProperty.all(Colors.grey.shade200),
                          ),
                          child: isSubmitting
                              ? Center(
                            child: SizedBox(
                              height: 24, width: 24,
                              child: CircularProgressIndicator(color: backgroundColor, strokeWidth: 3),
                            ),
                          )
                              : const Text('Verify', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ResendTimer(
                        onResend: () async {
                          try {
                            await ref.read(authNotifierProvider.notifier).resendOtps();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Codes resent successfully'), backgroundColor: Colors.green),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // ... Logo Section ...
            ],
          ),
        ),
      ),
    );
  }
}