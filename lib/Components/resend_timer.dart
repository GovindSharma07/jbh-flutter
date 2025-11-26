import 'dart:async';
import 'package:flutter/material.dart';

// --- Assuming accentOrange is defined somewhere, e.g.: ---
const Color accentOrange = Colors.orange;
// ---------------------------------------------------------

class ResendTimer extends StatefulWidget {
  const ResendTimer({Key? key}) : super(key: key);

  @override
  State<ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<ResendTimer> {
  // The total duration for the countdown
  static const int _initialSeconds = 50;

  // The current remaining time
  int _remainingSeconds = _initialSeconds;

  // The timer object
  Timer? _timer;

  // Boolean to track if the timer is active
  bool _isTimerActive = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is removed from the tree
    _timer?.cancel();
    super.dispose();
  }

  /// Starts the countdown timer
  void _startTimer() {
    setState(() {
      _remainingSeconds = _initialSeconds;
      _isTimerActive = true;
    });

    // Create a periodic timer that fires every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        // If time is remaining, decrement the counter and update the UI
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // If countdown is finished
        _timer?.cancel(); // Stop the timer
        setState(() {
          _isTimerActive = false; // Set state to show the "Resend" button
        });
      }
    });
  }

  /// Formats the remaining seconds into a "MM:SS" string
  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60; // Integer division
    int seconds = totalSeconds % 60;  // Modulo

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    // Use a ternary operator to show the timer or the "Resend" button
    return _isTimerActive
        ? RichText(
      text: TextSpan(
        // Your original "Resend : " text
        text: 'Resend : ',
        style: const TextStyle(color: Colors.white, fontSize: 16),
        children: [
          // The dynamic countdown timer text
          TextSpan(
            text: _formatTime(_remainingSeconds), // Calls the format helper
            style: const TextStyle(
              color: accentOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    )
        : TextButton(
      // When timer is inactive, show a button
      onPressed: _startTimer, // Pressing it restarts the timer
      child: const Text(
        'Resend',
        style: TextStyle(
          color: accentOrange,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}