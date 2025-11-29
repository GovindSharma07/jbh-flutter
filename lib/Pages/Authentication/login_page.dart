import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Models/user_model.dart';
import '../../app_routes.dart';
import '../../state/auth_notifier.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // 1. Success: Logged in
      // NEW CODE (Copy this)
      if (next.token != null && next.user != null) {
        // Determine where to go based on role
        String nextRoute = AppRoutes.home; // Default to Student

        if (next.user?.role == 'admin') {
          nextRoute = AppRoutes.adminDashboard;
        }
        // Future: else if (next.user?.role == 'instructor') ...

        Navigator.pushNamedAndRemoveUntil(
          context,
          nextRoute,
              (route) => false,
        );
      }
      // 2. Unverified: Navigate to Verification (Check tempEmail)
      else if (!next.isLoading && next.error == null && next.tempEmail != null) {
        // Only navigate if we haven't just come from a state that already had this email
        if (previous?.tempEmail != next.tempEmail) {
          Navigator.pushNamed(context, AppRoutes.verification);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please verify your account to continue.')),
          );
        }
      }
      // 3. Error: Show Snackbar (Fix double showing)
      else if (next.error != null && (previous == null || previous.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isSubmitting = authState.isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 60.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Login to your account',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 50),

                // --- Email ---
                const Text('Gmail', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                    if (!emailValid) return 'Please enter a valid email format';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    errorStyle: const TextStyle(color: Color(0xFFE94B3C), fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Password ---
                const Text('Password', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    errorStyle: const TextStyle(color: Color(0xFFE94B3C), fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFFE94B3C))),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(authNotifierProvider.notifier).login(
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Color(0xFF1D4D6B))
                        : const Text(
                      'Login',
                      style: TextStyle(color: Color(0xFF1D4D6B), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Create Account ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Don't have account? ", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text('Create Now', style: TextStyle(color: Color(0xFF3498DB), fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                const SizedBox(height: 50),
                // Social Icons Row (Simplified for brevity)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon("assets/icons/google_logo.png"),
                    const SizedBox(width: 30),
                    _buildSocialIcon("assets/icons/facebook_logo.png"),
                    const SizedBox(width: 30),
                    _buildSocialIcon('assets/icons/insta_logo.png'),
                  ],
                ),
                const SizedBox(height: 50),

                // Footer Logo
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/icons/jbh_logo.png', height: 60, errorBuilder: (c,e,s)=> const Icon(Icons.image, size: 60, color: Colors.white54)),
                      const SizedBox(height: 10),
                      const Text('www.jbhtechacademy.com', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String imagePath) {
    return Container(
      width: 45, height: 45,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(8),
      child: Image.asset(imagePath, errorBuilder: (c,e,s) => const Icon(Icons.error, color: Colors.red, size: 20)),
    );
  }
}