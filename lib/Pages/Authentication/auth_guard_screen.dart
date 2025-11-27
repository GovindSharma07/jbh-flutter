import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/app_routes.dart';
import 'package:jbh_academy/state/auth_notifier.dart';

class AuthGuardScreen extends ConsumerStatefulWidget {
  const AuthGuardScreen({super.key});

  @override
  ConsumerState<AuthGuardScreen> createState() => _AuthGuardScreenState();
}

class _AuthGuardScreenState extends ConsumerState<AuthGuardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // State variables to track the two conditions
  bool _minTimeElapsed = false;
  bool _authCheckComplete = false;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 2. Start the minimum 3-second timer
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _minTimeElapsed = true;
        });
        _attemptNavigation();
      }
    });

    // 3. Check initial Auth State (in case it loaded instantly)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(authNotifierProvider);
      if (!state.isLoading) {
        _authCheckComplete = true;
        _attemptNavigation();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Central method to handle navigation logic
  void _attemptNavigation() {
    // Only navigate if BOTH the timer is done AND auth is finished
    if (_minTimeElapsed && _authCheckComplete) {
      final state = ref.read(authNotifierProvider);

      if (state.user != null && state.token != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. Listen for Auth State changes
    ref.listen(authNotifierProvider, (previous, next) {
      // If loading just finished
      if (previous?.isLoading == true && next.isLoading == false) {
        _authCheckComplete = true;
        _attemptNavigation();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            'assets/logo.png',
            width: 150,
            height: 150,
            // Handle error if asset is missing
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                  Icons.school,
                  size: 150,
                  color: Colors.white
              );
            },
          ),
        ),
      ),
    );
  }
}