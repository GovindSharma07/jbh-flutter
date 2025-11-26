import 'dart:async';
import 'package:flutter/material.dart';

const Color accentOrange = Colors.orange;

class ResendTimer extends StatefulWidget {
  // Add callback for the API call
  final Future<void> Function() onResend;

  const ResendTimer({super.key, required this.onResend});

  @override
  State<ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<ResendTimer> {
  static const int _initialSeconds = 30; // Reduced to 30s for better UX
  int _remainingSeconds = _initialSeconds;
  Timer? _timer;
  bool _isTimerActive = true;
  bool _isLoading = false; // To show loader during resend API call

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = _initialSeconds;
      _isTimerActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isTimerActive = false;
        });
      }
    });
  }

  Future<void> _handleResend() async {
    setState(() {
      _isLoading = true;
    });

    // Call the provided function (API call)
    await widget.onResend();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _startTimer(); // Restart timer on success
    }
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    return _isTimerActive
        ? RichText(
      text: TextSpan(
        text: 'Resend : ',
        style: const TextStyle(color: Colors.white, fontSize: 16),
        children: [
          TextSpan(
            text: _formatTime(_remainingSeconds),
            style: const TextStyle(
              color: accentOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    )
        : TextButton(
      onPressed: _handleResend,
      child: const Text(
        'Resend OTP',
        style: TextStyle(
          color: accentOrange,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}